---
name: git-worktree
description: >-
  Verify remotes, then detect or create an isolated git worktree and branch,
  move the agent root into it, and verify pwd/branch before edits. Accepts
  base= and branch= from callers. Use when starting feature work, git-issue /
  git-pipeline / git-implement isolation, or when isolation from the primary
  checkout is required. Standalone; if Superpowers using-git-worktrees is
  already loaded, defer to it for mechanics after remotes are verified.
license: Apache-2.0
compatibility: >-
  Agentskills.io clients (Cursor, Claude Code, …). Optional Lola install.
  Superpowers optional peer.
metadata:
  author: Leonardo Gallego
  version: "1.1.1"
  collection: workflow
---

# git-worktree

## Overview

1. **Verify remotes** — do not assume `origin` is the canonical repo or the
   push target (forks use `upstream` + `origin`).
2. Ensure work happens in an isolated linked worktree on its own branch.
3. Prefer native host tools, then `git worktree add`. Never nest worktrees.

**Announce at start:** "Using git-worktree (remotes + isolation)."

If Superpowers `using-git-worktrees` is already loaded, still run
[Remotes](#0-verify-remotes) first, then defer isolation mechanics to that skill.

## When to use / not

**Use when:** `git-issue`, `git-pipeline`, or `git-implement` needs isolation;
user asks for a worktree; multiple agents may share the repo.

**Not when:** already inside the correct linked worktree on the assigned
branch (still re-check remotes if about to fetch/push). Do not nest worktrees.

## Parameters (from caller)

| Param | Required | Meaning |
|-------|----------|---------|
| `branch=` | Yes when entry assigns one | New or target branch name (`<type>/<n>-<slug>`) |
| `base=` | No (default below) | Ref to branch from — e.g. `upstream/main`, `origin/main`, or a prior chain branch name |

Defaults after remotes are resolved:

- `git-issue` / standalone: `base=<base-remote>/<default-branch>`
- `git-pipeline` later-in-chain: `base=<previous-issue-branch>` (local or remote-tracking)

## Instructions

### 0. Verify remotes

**Before any fetch, worktree create, or push.** Never assume `origin` is
canonical or that it matches the issue’s `owner/repo`.

```bash
git remote -v
git branch -vv
git symbolic-ref refs/remotes/*/HEAD 2>/dev/null || true
```

Build a **remote map** and record it for the session:

| Role | How to choose |
|------|----------------|
| **Issue / base remote** | Remote whose URL `owner/repo` matches the GitHub issue (or user-stated canonical repo). Often `upstream` on a fork, else `origin`. |
| **Push remote** | Where this clone may push feature branches. On a fork workflow: usually `origin` (fork). On a shared clone with write access to canonical: same as base remote. |
| **Default branch** | `git remote show <base-remote>` → `HEAD branch`, or `main`/`master` from `refs/remotes/<base-remote>/HEAD`. |

Rules:

1. If only one remote exists, it fills both roles — still print its URL and
   confirm it matches the issue repo (or ask).
2. If `origin` and `upstream` both exist: **do not guess**. Match issue/PR
   `owner/repo` to URLs. Typical fork: base=`upstream`, push=`origin`.
3. If no remote matches the issue’s `owner/repo`: **STOP** and ask whether to
   add a remote, use a fork workflow, or if the issue repo was wrong.
4. If multiple remotes match or roles stay ambiguous: **STOP** and ask.
5. Prefer SSH URLs for push/fetch in sandbox (`git-sandbox`). HTTPS → switch
   or stop.
6. Subsequent steps use `<base-remote>` and `<push-remote>` from this map —
   not a hard-coded `origin` unless the map says so.

Report briefly: `base-remote=… url=…; push-remote=… url=…; default-branch=…`.

### 1. Detect existing isolation

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
git worktree list
```

Submodule guard — if this returns a path, treat as a normal repo (not a worktree):

```bash
git rev-parse --show-superproject-working-tree 2>/dev/null
```

- If `GIT_DIR != GIT_COMMON` and not a submodule: already in a linked worktree.
  Report path + branch. Do **not** create another worktree. If `branch=` was
  assigned and does not match: **STOP** (do not `reset --hard` on the wrong
  branch).
- List other worktrees/branches peer agents may own. Do not reuse them.
- If in the primary checkout: continue to create isolation.

### 2. Consent

- **Required isolation** (caller is `git-issue` / `git-pipeline` /
  `git-implement`, or user required isolation): create a worktree — do not ask
  to work in place.
- **Optional isolation**: ask once. If declined, stop this skill.

### 3. Fetch base

```bash
git fetch <base-remote>
# when base= is another local branch / prior chain branch, ensure it exists
```

Resolve `base=`:

- Unset → `<base-remote>/<default-branch>`
- `origin/main` style → rewrite `origin` to `<base-remote>` if the map says
  base-remote is not named origin
- Bare branch name → use as-is if it exists locally after fetch

### 4. Create isolated workspace

#### 4a. Native tools (preferred)

Use the host’s worktree helper when available, then move the agent root into
that directory **before any edits**:

| Host | Tools / actions |
|------|-----------------|
| Cursor | Worktree helpers if present; then `move_agent_to_root` |
| Claude Code | `EnterWorktree` or equivalent |
| Other | Host-specific workspace switch |

Pass/create branch named `branch=`. Native tools own path placement — do not
also run bare `git worktree add` if the host already created one.

#### 4b. Git fallback

Only when no native create tool is available.

**Directory priority:** (1) path from user/issue prompt, (2) existing
`.worktrees/` or `.claude/worktrees/` or `worktrees/`, (3) default `.worktrees/`.

```bash
git check-ignore -q .worktrees 2>/dev/null \
  || git check-ignore -q .claude/worktrees 2>/dev/null \
  || git check-ignore -q worktrees 2>/dev/null
```

If the chosen parent is not ignored, add it to `.gitignore` before creating.

```bash
mkdir -p "$LOCATION"
git worktree add "$LOCATION/$BRANCH_NAME" -b "$BRANCH_NAME" "$BASE_REF"
```

Then `cd` / move agent root to that path.

If sandbox blocks `git worktree add`, report the failure. Under
`git-issue` / `git-pipeline` / `git-implement`: **STOP**.

### 5. Verify before any edits

```bash
pwd
git branch --show-current
git rev-parse --abbrev-ref HEAD
```

- `pwd` must be the worktree path.
- Branch must equal `branch=` when assigned.
- If mismatch: **STOP**.

### 6. Light project setup (optional)

Only what the task needs. **Python note:** root `.venv` often points at the
primary tree — prefer
`pytest --override-ini="pythonpath=src"` from the worktree cwd.

## Failure modes

| Symptom | Fix |
|---------|-----|
| Assumed `origin` wrong (fork) | Remap: base=`upstream`, push=`origin` |
| Issue repo ≠ any remote URL | STOP; add remote or fix issue/repo |
| Nested worktree | Reuse current isolation |
| Wrong branch after create | STOP; do not hard-reset |
| Path not gitignored | Add ignore before `worktree add` |
| Peer owns branch/worktree | STOP; new branch name from base |
| Sandbox blocks `worktree add` | Report; required-isolation callers STOP |

## Related skills

- `git-issue` — single-issue entry (always runs §0 + isolation)
- `git-pipeline` — batch entry (same; stacked `base=`)
- `git-implement` — calls this with `base=` / `branch=`
- `git-pr` — uses push-remote / base-remote from §0
- `git-sandbox` — SSH remotes, push tooling
- Superpowers `using-git-worktrees` — optional peer after remotes
