---
name: git-issue
description: >-
  Single-issue GitHub workflow: verify remotes, fetch one issue by number or
  URL, then run assess → plan (if needed) → implement → PR with base on the
  default branch (no stacking). Use when the user says git-issue 123, passes
  one issue URL, or wants one focused PR without a multi-issue pipeline.
license: Apache-2.0
compatibility: >-
  Agentskills.io clients (Cursor, Claude Code, …). Optional Lola install.
metadata:
  author: Leonardo Gallego
  version: "1.2.0"
  collection: workflow
---

# git-issue

## Overview

**One issue only.** Number-first: `git-issue 123` or an issue URL. No dependency
DAG, no stacked PRs (use `git-pipeline` for batch/stacks).

**Thin orchestrator** — call phase skills; do not paste their procedures.
Remotes + isolation: `git-worktree`. PR/Closes/merge details: `git-pr`.

## When to use / not

**Use when:** exactly one issue; one PR from the default branch.

**Not when:** multiple issues, dependency chains, or sequential stack merges →
`git-pipeline`.

## Hard stops

Shared with `git-pipeline` (policy only; mechanics live in linked skills):

1. Remotes before any fetch/push — `git-worktree` §0; issue `owner/repo` must
   match **base-remote**.
2. Never edit the primary checkout; never reuse a peer agent’s worktree/branch.
3. Required isolation via `git-worktree` before implement edits.
4. Verify `pwd` + branch before every commit/push (`git-worktree` /
   `git-implement`).
5. Collision with peer-owned / out-of-scope files → STOP and report.
6. Subagents do not push — `git-sandbox`.
7. Partial progress, `Closes`/`Fixes`, merge-via-API → **`git-pr` only** (load
   `git-closes` there).

## Instructions

### 1. Parse input

Accept `#123`, `123`, or a full issue URL. If missing: **STOP** and ask.

### 2. Remotes + fetch issue

1. `git-worktree` §0 — confirm **base-remote** / **push-remote**.
2. Resolve **forge provider** (`.git-pipeline.yml` → URL infer → default
   `github`) via `git-sandbox`. Unsupported → **STOP** (git-only still OK).
3. Fetch issue through that provider. Closed/obsolete → STOP.
4. Load `.git-pipeline.yml` if present (read only; no full infer/confirm).

### 3. Phase sequence

1. `git-assess` — pass payload  
2. `git-plan` — medium/large only; skip trivial/small  
3. `git-implement` — `branch=<type>/<n>-<slug>`,
   `base=<base-remote>/<default-branch>` (never stacked)  
4. `git-pr` — push-remote; one PR  

### 4. Done

Report PR URL, deferred issues (or none), remotes used.

## Related skills

- `git-pipeline` — batch + stacking
- `git-worktree` — remotes + isolation
- `git-assess` → `git-plan` → `git-implement` → `git-pr`
- `git-sandbox`, `git-closes`
