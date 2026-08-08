---
name: git-issue
description: >-
  Multi-agent GitHub issue workflow: preflight, isolated worktree, scope
  discipline, review gates, one focused PR, safe merge, and deferred-work
  tracking. Use when implementing a tracked issue with parallel agents, or when
  the user pastes an issue prompt / says follow git-issue. Requires git-worktree
  for isolation mechanics.
license: Apache-2.0
compatibility: >-
  Agentskills.io clients (Cursor, Claude Code, …). Optional Lola install.
  Standalone via git-worktree; Superpowers optional peer.
metadata:
  author: Leonardo Gallego
  version: "1.0.0"
  collection: workflow
---

# git-issue

## Overview

You are one of several agents that may share this repo. Never edit the primary
checkout while others may be active. Load `git-worktree` for isolation
mechanics. Stay inside issue scope. Ship one focused PR (or report partial
progress without closing the issue).

Issue fields: see [prompt-template.md](prompt-template.md).

## When to use / not

**Use when:** implementing a GitHub (or similar) issue; user says follow
`git-issue`; multi-agent / worktree isolation is required end-to-end.

**Not when:** drive-by questions, read-only exploration, or pure docs with no
repo edits (unless the user still wants the workflow).

## Empty prompt STOP

If this turn only names the skill (or an old isolation preamble) and there is
**no** Issue / Branch / Goal / Tests / Done section, **STOP** and ask for the
full issue prompt using [prompt-template.md](prompt-template.md). Do not invent
scope.

## Instructions

### 0. Preflight (before any edits)

1. `git fetch origin` (or the configured remote).
2. Confirm the issue is still open and not already fixed on the base branch
   (issue state + search merged PRs). If fixed or obsolete: **STOP** and report.
3. `git worktree list` — note paths/branches other agents own. Do not reuse them.
4. Load `git-closes` before any commit/PR text that uses `Closes` / `Fixes`.

### 1. Isolate with `git-worktree`

Follow `git-worktree` **before any edits**:

- New worktree + **new** branch from `origin/<base>` (default `origin/main`).
- Branch name must match the `Branch:` line in the prompt.
- Move the agent root into the worktree (Cursor: `move_agent_to_root`, etc.).
- Verify `pwd` and `git branch --show-current`.

Do not checkout/reset/stash in the primary repo. Do not reuse another agent’s
branch or worktree. Never push to a branch that already has a merged PR (remote
may be deleted — treat as hard stop; create a new branch from base instead).

### 2. Re-verify before every commit/push

```bash
pwd                          # must be this worktree
git branch --show-current    # must match assigned Branch:
```

### 3. Scope discipline

Stay inside the issue Goal. Respect Out of scope / Independent-of notes — no
adjacent refactors or “while I’m here” cleanups.

Soft-align with a related issue only via a tiny shared helper in an allowed
layer (prefer the repo’s foundation/shared layer). If the natural fix would
edit files owned by another in-flight agent or an out-of-scope issue: **STOP**
and report — do not borrow their module; extract a neutral helper or defer with
an issue.

### 4. Implement

Do the minimum change that satisfies Goal + Tests. Use `git-sandbox` when
push/PR/API ops fail under a restricted sandbox.

### 5. Before opening / asking to merge the PR

1. Re-fetch base. If it advanced, rebase or merge it into your branch **in this
   worktree only**.
2. Load and follow project review skills when present (architecture review,
   language quality packs such as `pep8-review`, `try-except`, `tighten-types`,
   `contract-docstrings`, etc.). Prefer deep review over a shallow skim.
   Respect layer contracts the project documents (e.g. no forbidden layer hops).
3. Iterate until no Error/Warning findings remain. Fix in this PR; do not merge
   with open Warnings unless the user explicitly accepts them.
4. Fix trivial Info findings in the same PR when small. Only defer non-trivial
   work.
5. For each deferred item: comment on an existing issue or open one; link
   deferred issues in the PR body. If nothing was deferred, say so.
6. Run the Tests commands from the issue prompt (and lint on touched files).

### 6. Open one focused PR

- Full completion: `Closes #<n>` (after `git-closes` verification).
- Partial progress: do **not** close — say `Partial progress on #<n>`, update
  the issue with a done/still-todo checklist, leave `Closes` for a later PR.
- If the issue asks to pick among design surfaces, pick one and document the
  choice in the PR body.

### 7. Collision STOP

If you collide with another agent’s files: **STOP** and report. Do not “fix”
by merging their work into yours.

### 8. Merge (when asked / when Done says merge)

Wait until required CI is green and the PR is mergeable.

Prefer:

```bash
gh pr merge <n> --merge --delete-branch
```

If that fails because the default branch is checked out in another worktree:
do **not** checkout/reset the primary repo. Merge via API, then delete the
remote feature branch if still present:

```bash
gh api repos/<owner>/<repo>/pulls/<n>/merge -X PUT -f merge_method=merge
git push origin --delete <branch-name>
```

Under sandbox / broken `gh` auth, use GitHub MCP (see `git-sandbox`) for the
API merge, and git SSH for branch delete when needed.

Confirm:

```bash
gh pr view <n> --json state,mergedAt,mergeCommit
```

After a remote-only merge, sync local default branch in a safe worktree (or
fetch) — do not disturb another agent’s primary checkout. Prefer:

```bash
git fetch origin
# update local main only inside a worktree that already has it, or leave primary alone
```

### 9. Report

Report deferred items with issue links, or explicitly state none.

## Related skills

- `git-worktree` — isolation mechanics (required)
- `git-closes` — verify issue numbers before Closes/Fixes
- `git-sandbox` — restricted-environment git/GitHub tooling
- `git-ignore-ai` — optional if the change set produces ignore churn
