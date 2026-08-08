---
name: git-pipeline
description: >-
  Multi-issue GitHub pipeline: verify remotes, triage and dependency DAG,
  stacked worktrees/PRs where needed, then assess → plan → implement → PR per
  issue and sequential merge. Use when the user passes multiple issue numbers,
  asks for issue-pipeline style batch processing, or needs stacked PRs.
license: Apache-2.0
compatibility: >-
  Agentskills.io clients (Cursor, Claude Code, …). Optional Lola install.
metadata:
  author: Leonardo Gallego
  version: "0.1.0"
  collection: workflow
---

# git-pipeline

## Overview

**Batch / stacked orchestrator.** Entry: `git-pipeline #1 #2 #3`. Thin skill:
sequences triage + phase skills; does not duplicate their procedures.

**Stub (M1):** structure and contracts only. Full triage/foundation/conventions/
merge-sequence content lands in M2 from `issue-pipeline-skill`.

## When to use / not

**Use when:** multiple issues; dependencies; stacked PRs; full pipeline run.

**Not when:** a single standalone issue → prefer `git-issue`.

## Hard stops

- Verify remotes before any fetch/push (`git-worktree` §0). Match each issue’s
  `owner/repo` to **base-remote** (STOP if mismatch/ambiguous).
- Never edit the primary checkout; never reuse peer worktrees/branches.
- Subagents do not push (`git-sandbox`).
- Collision STOP; partial progress / deferrals via `git-pr`.
- Merge gate + sequential merge owned **here**; single-PR merge call → `git-pr`.

## Instructions (contract)

### 1. Remotes

Run `git-worktree` §0. Record `base-remote`, `push-remote`, default branch.

### 2. Foundation + conventions (M2)

Load `foundation.md` / `conventions.md` when present; write/read
`.git-pipeline.yml`. (Files added in M2.)

### 3. Triage (M2)

Fetch all issues; parse deps; DAG; chains; skips. Optional `triage-prompt.md`.

### 4. Per issue

For each issue in order:

1. `git-assess`
2. `git-plan` if medium/large
3. `git-implement` with `branch=<type>/<n>-<slug>` and
   `base=<base-remote>/<default>` (first/standalone) or prior issue branch
   (later in chain)
4. `git-pr` (push to **push-remote**)

### 5. Merge gate + sequential merge (M2)

Human approval; merge via `git-pr` mechanics; worktree cleanup; completion
report.

## Related skills

- `git-issue` — single-issue entry
- `git-worktree`, `git-assess`, `git-plan`, `git-implement`, `git-pr`
- `git-sandbox`, `git-closes`
