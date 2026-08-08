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
  version: "1.1.0"
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
| PR | `git-pr` | **push-remote**; stack PR base when not first |

`base=` for implement: `<base-remote>/<default>` (first/standalone) or previous
issue branch (later in chain).

### 5. Merge gate

Present [completion-report.md](completion-report.md). Wait for human approval.

### 6. Sequential merge

For each chain, in order:

1. Invoke `git-pr` merge mechanics (API path if needed) for the **first** open
   PR in the chain — while primary may still hold the default branch.
2. **Retarget** the next stacked PR: set its base from the merged feature
   branch to `<default-branch>` (GitHub: update PR `base`). Merge only after
   the PR is mergeable against that new base (rebase/retarget conflicts →
   fix in that issue’s worktree, do not reset primary).
3. Repeat merge → retarget for the rest of the chain.
4. Remove merged worktrees when safe; delete remote feature branches when
   appropriate.
5. `git fetch <base-remote>` between merges; ff-only update a **safe** default
   worktree if you need local `main` — never steal primary from a peer.

### 7. Done

Final report: merged / skipped / failed; deferred issue links.

## Related skills

- `git-issue` — single-issue entry
- `git-worktree` — remotes + isolation
- `git-assess` → `git-plan` → `git-implement` → `git-pr`
- `git-sandbox`, `git-closes`
