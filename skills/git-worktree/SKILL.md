---
name: git-worktree
description: >-
  Detect or create an isolated git worktree and branch, move the agent root
  into it, and verify pwd/branch before edits. Use when starting feature work,
  parallel-agent issue work, or when isolation from the primary checkout is
  required. Standalone; if Superpowers using-git-worktrees is already loaded,
  defer to it.
license: Apache-2.0
compatibility: >-
  Agentskills.io clients (Cursor, Claude Code, …). Optional Lola install.
  Superpowers optional peer.
metadata:
  author: Leonardo Gallego
  version: "1.0.0"
  collection: workflow
---

# git-worktree

## Overview

Ensure work happens in an isolated linked worktree on its own branch. Prefer
native host tools, then `git worktree add`. Never nest worktrees. Never edit
the primary checkout when isolation was requested.

**Announce at start:** "Using git-worktree to set up an isolated workspace."

If Superpowers `using-git-worktrees` is already loaded in this session, follow
that skill instead of re-deriving steps below.

## When to use / not

**Use when:** starting implementation, `git-issue` requires isolation, user
asks for a worktree, or multiple agents may share the repo.

**Not when:** already inside the correct linked worktree on the assigned
branch (verify and continue). Do not create a second worktree for the same job.

## Instructions

### 0. Detect existing isolation

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
  Report path + branch. Do **not** create another worktree. If the branch must
  match an assigned name and it does not, **STOP** and report (do not
  `reset --hard` on the wrong branch).
- If in the primary checkout: continue to create isolation.

List other worktrees/branches other agents may own. Do not reuse them.

### 1. Consent

- **Required isolation** (`git-issue`, user said parallel agents / never touch
  primary, or user named this skill): create a worktree — do not ask to work
  in place.
- **Optional isolation** (no policy declared): ask once whether to set up a
  worktree. If declined, stay in place and stop this skill.

### 2. Create isolated workspace

Base: `origin/<default-branch>` (usually `main`). Fetch first when network allows:

```bash
git fetch origin
```

Prefer creating from `origin/main` (or the repo default) unless the user named
another base.

#### 2a. Native tools (preferred)

Use the host’s worktree helper when available, then move the agent root into
that directory **before any edits**:

| Host | Tools / actions |
|------|-----------------|
| Cursor | Worktree helpers if present; then `move_agent_to_root` to the worktree path |
| Claude Code | `EnterWorktree` or equivalent |
| Other | Host-specific worktree / workspace switch |

Native tools own path placement. Do not also run bare `git worktree add` if the
host already created one (avoids phantom state).

#### 2b. Git fallback

Only when no native create tool is available.

**Directory priority:** (1) path from user/issue prompt, (2) existing
`.worktrees/` or `.claude/worktrees/` or `worktrees/`, (3) default `.worktrees/`.

```bash
git check-ignore -q .worktrees 2>/dev/null \
  || git check-ignore -q .claude/worktrees 2>/dev/null \
  || git check-ignore -q worktrees 2>/dev/null
```

If the chosen parent is not ignored, add it to `.gitignore` (and commit that
fix if appropriate) before creating the worktree.

```bash
mkdir -p "$LOCATION"
git worktree add "$LOCATION/$BRANCH_NAME" -b "$BRANCH_NAME" origin/main
# or: git worktree add "$LOCATION/$BRANCH_NAME" -b "$BRANCH_NAME" origin/<default>
```

Then `cd` / move agent root to `$LOCATION/$BRANCH_NAME`.

If sandbox blocks `git worktree add`, report the failure. Under `git-issue`,
**STOP** (do not silently edit the primary). For optional isolation, ask
whether to continue in place.

### 3. Verify before any edits

```bash
pwd
git branch --show-current
git rev-parse --abbrev-ref HEAD
```

- `pwd` must be the new worktree path.
- Branch must equal the assigned branch (from the issue prompt or agreed name).
- If mismatch: **STOP**. Do not reset, commit, or push on the wrong branch.

### 4. Light project setup (optional)

Only what the task needs (deps install). Do not run the full test suite unless
the user or `git-issue` prompt requires a baseline.

**Python note:** a root `.venv` often points at the primary tree. Prefer the
primary venv with imports from this worktree, e.g.
`pytest --override-ini="pythonpath=src"` from the worktree cwd. Do not create a
second venv in the worktree unless the user asks.

## Failure modes

| Symptom | Fix |
|---------|-----|
| Nested worktree | Detect in step 0; reuse current isolation |
| Wrong branch after create | STOP; report; do not hard-reset |
| Path not gitignored | Add ignore rule before `worktree add` |
| Branch/worktree owned by another agent | STOP; pick a new branch name from base |
| Sandbox blocks `worktree add` | Report; under `git-issue`, STOP |

## Related skills

- `git-issue` — process that requires this isolation
- `git-sandbox` — push/fetch tooling inside restricted sandboxes
- Superpowers `using-git-worktrees` — optional peer if already loaded
