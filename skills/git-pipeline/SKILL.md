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
  version: "1.0.0"
  collection: workflow
---

# git-pipeline

## Overview

Batch / stacked orchestrator. Thin: sequences triage + phase skills; does not
paste their bodies. Adapted from `issue-pipeline-skill` (see pack `NOTICE`).

Helpers: [foundation.md](foundation.md), [conventions.md](conventions.md),
[triage-prompt.md](triage-prompt.md),
[completion-report.md](completion-report.md).

## When to use / not

**Use when:** multiple issues; dependencies; stacked PRs.

**Not when:** one standalone issue → `git-issue`.

## Hard stops

- `git-worktree` §0 remotes before any fetch/push; issue repos must match
  **base-remote**.
- Never edit primary checkout; never reuse peer worktrees/branches.
- Subagents do not push (`git-sandbox`).
- Collision STOP; partial progress / deferrals via `git-pr`.
- Merge gate + sequential merge + worktree prune owned **here**.

## Instructions

### 1. Remotes

Run `git-worktree` §0. Record `base-remote`, `push-remote`, default branch.

### 2. Foundation + conventions

Follow [foundation.md](foundation.md) then [conventions.md](conventions.md).

### 3. Triage

Parse input numbers/URLs. Dispatch or run [triage-prompt.md](triage-prompt.md):
fetch issues, deps, DAG, chains, skips, risk. Tooling via `git-sandbox`.

Host-neutral run state: checklist of issues (pending / in progress / done /
skipped / failed). Use host task APIs when available.

### 4. Per-issue loop

For each issue in chain order (then standalones):

| Step | Skill | Notes |
|------|-------|-------|
| Assess | `git-assess` | Skip remainder if outdated |
| Plan | `git-plan` | Skip if trivial/small |
| Implement | `git-implement` | `branch=<type>/<n>-<slug>`; `base=` default or prior branch |
| PR | `git-pr` | Push to **push-remote**; stack base when not first |

First in chain / standalone: `base=<base-remote>/<default-branch>`.  
Later in chain: `base=<previous-issue-branch>`.

### 5. Merge gate

After PRs exist: present [completion-report.md](completion-report.md). Wait for
human approval (only required human checkpoint for merge).

### 6. Sequential merge

For each chain in order, merge PRs bottom-up or as stack requires:

1. Call `git-pr` single-PR merge mechanics (API if needed).
2. Update next stacked PR base if required.
3. Remove worktrees for merged branches when safe.
4. Fetch **base-remote** between merges.

Do not checkout/reset the primary repo to merge.

### 7. Done

Final completion report: PRs merged/skipped/failed; deferred issue links.

## Related skills

- `git-issue` — single-issue entry
- `git-worktree`, `git-assess`, `git-plan`, `git-implement`, `git-pr`
- `git-sandbox`, `git-closes`
