---
name: git-pipeline
description: >-
  Multi-issue GitHub pipeline: verify remotes, load foundation/conventions,
  triage dependency DAG, stacked worktrees/PRs, assess → plan → implement → PR
  per issue, merge gate and sequential merge. Use for multiple issue numbers,
  stacks, or full batch processing; prefer git-issue for one standalone issue.
license: Apache-2.0
compatibility: >-
  Agentskills.io clients (Cursor, Claude Code, …). Optional Lola install.
metadata:
  author: Leonardo Gallego
  version: "1.2.0"
  collection: workflow
---

# git-pipeline

## Overview

Batch / stacked orchestrator. **Thin** — sequences triage + phase skills; does
not paste assess/plan/implement/PR bodies. Single-PR merge mechanics stay in
`git-pr`; **this** skill owns merge gate, order, and worktree prune.

Helpers: [foundation.md](foundation.md), [conventions.md](conventions.md),
[triage-prompt.md](triage-prompt.md),
[completion-report.md](completion-report.md).

## When to use / not

**Use when:** multiple issues; dependencies; stacked PRs.

**Not when:** one standalone issue → `git-issue`.

## Hard stops

Shared with `git-issue` (policy only; mechanics live in linked skills):

1. Remotes before any fetch/push — `git-worktree` §0; each issue `owner/repo`
   must match **base-remote**.
2. Never edit the primary checkout; never reuse a peer agent’s worktree/branch.
3. Required isolation via `git-worktree` before implement edits.
4. Verify `pwd` + branch before every commit/push.
5. Collision with peer-owned / out-of-scope files → STOP and report.
6. Subagents do not push — `git-sandbox`.
7. Partial progress, `Closes`/`Fixes`, single-PR merge-via-API → **`git-pr`**.
8. Multi-PR merge order + worktree cleanup after merge → **this skill** (call
   `git-pr` per merge; never checkout/reset primary to merge).

## Instructions

### 1. Remotes

`git-worktree` §0. Record `base-remote`, `push-remote`, default branch.

### 2. Foundation + conventions

[foundation.md](foundation.md) then [conventions.md](conventions.md). Resolve
`forge.provider` (default `github`). Unknown/unsupported → **STOP** API steps;
plain git may continue (`git-sandbox`).

### 3. Triage

Parse numbers/URLs. Run [triage-prompt.md](triage-prompt.md) (or subagent).
Tooling: `git-sandbox`. Track run state (checklist / host tasks).

### 4. Per-issue loop

| Step | Skill | Notes |
|------|-------|-------|
| Assess | `git-assess` | Stop issue if outdated |
| Plan | `git-plan` | Skip trivial/small |
| Implement | `git-implement` | `branch=<type>/<n>-<slug>` |
| PR | `git-pr` | **push-remote**; stack PR base when not first — see **stack CI** |

`base=` for implement: `<base-remote>/<default>` (first/standalone) or previous
issue branch (later in chain).

#### Stack CI (avoid rebuild cascades)

When several stacked PRs all run CI, merging the first invalidates the rest
(they need a rebase onto the new default). A chain of N PRs can trigger
roughly N + (N−1) + … rebuilds. Mitigate with
`stack_ci` in `.git-pipeline.yml` (default **`serial`**):

| Mode | Behavior |
|------|----------|
| **`serial`** (default) | Implement the whole chain in worktrees if useful, but only **one** PR is “CI-active” at a time: open/ready the first; keep later PRs **unopened** or **draft** until the previous merges. After merge, refresh the next branch (below), then open/ready it and wait for CI. |
| **`parallel`** | Open the full stack for review (old behavior). Expect CI thrash on each merge; still **must** rebase + re-green before merging each next PR. Use only when review latency matters more than CI cost. |

Also prefer fewer wider PRs when CI is expensive. If the host has a **merge
queue** that rebases automatically, prefer it and do not race manual merges.

### 5. Merge gate

Present [completion-report.md](completion-report.md). Wait for human approval.
Remind whether `stack_ci` is serial or parallel.

### 6. Sequential merge

For each chain, in order:

1. Invoke `git-pr` merge mechanics (API path if needed) for the **first**
   CI-green PR — while primary may still hold the default branch.
2. `git fetch <base-remote>` so local refs see the new default tip.
3. **Refresh the next stacked branch** (required — retarget alone is not
   enough):
   - In that issue’s worktree: rebase (or merge) onto
     `<base-remote>/<default-branch>` (or the new stack parent if mid-chain
     still needs a non-default base).
   - Push with `--force-with-lease` to **push-remote** (main session only).
   - Set the PR `base` to `<default-branch>` when it should land on default
     (GitHub: update PR base).
   - Conflicts → fix in that worktree; do not reset primary.
4. **Wait for required CI green on the refreshed tip.** Ignore CI results from
   before the rebase — they are stale.
5. Merge that PR via `git-pr`; repeat steps 2–5 for the rest of the chain.
6. Under `stack_ci: serial`, open/undraft the next PR only at step 3–4 (not
   before the previous merge).
7. Remove merged worktrees when safe; delete remote feature branches when
   appropriate. Ff-only update a **safe** default worktree if needed — never
   steal primary from a peer.

### 7. Done

Final report: merged / skipped / failed; deferred issue links; note how many
rebases/CI waits ran.

## Related skills

- `git-issue` — single-issue entry
- `git-worktree` — remotes + isolation
- `git-assess` → `git-plan` → `git-implement` → `git-pr`
- `git-sandbox`, `git-closes`
