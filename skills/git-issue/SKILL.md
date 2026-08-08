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
  version: "1.1.0"
  collection: workflow
---

# git-issue

## Overview

**One issue only.** Number-first: `git-issue 123` or an issue URL. No dependency
DAG, no stacked PRs (use `git-pipeline` for batch/stacks).

This skill is a **thin orchestrator**. It does not re-specify assess/plan/
implement/PR steps — it calls those skills. Isolation and remotes:
`git-worktree`.

## When to use / not

**Use when:** exactly one issue; user wants a single PR from the default branch.

**Not when:** multiple issues, dependency chains, or sequential merge of a
stack → `git-pipeline`.

## Hard stops

- Verify remotes before any fetch/push ([git-worktree § Remotes](../git-worktree/SKILL.md)).
- Never edit the primary checkout; never reuse a peer agent’s worktree/branch.
- Verify `pwd` + branch before every commit/push.
- Collision with peer-owned files → STOP and report.
- Partial progress → no `Closes`; checklist on the issue; deferrals → linked issues.
- Merge-via-API if the default branch is checked out elsewhere (`git-pr`).

## Instructions

### 1. Parse input

Accept `#123`, `123`, or a full issue URL. Derive `owner/repo` from the URL or
from the verified **issue/base remote** after step 2. If the number is missing:
**STOP** and ask (do not invent scope from chat alone).

### 2. Remotes + fetch issue

1. Follow `git-worktree` **§0 Verify remotes**. Confirm issue `owner/repo`
   matches **base-remote** (or STOP).
2. Fetch issue via GitHub MCP or `gh` per `git-sandbox` (title, body, labels,
   state). If closed/obsolete vs base branch: STOP and report.
3. Load `.git-pipeline.yml` if present (conventions only; do not run full
   infer/confirm — that is `git-pipeline`).

### 3. Phase sequence

Call in order (do not paste their bodies here):

1. **`git-assess`** — pass issue payload; out-of-scope exclusions
2. **`git-plan`** — only if assess scope is medium/large (see review matrix in
   PIPELINE_PLAN / `git-plan`); trivial/small → skip
3. **`git-implement`** — `branch=<type>/<n>-<slug>`, `base=<base-remote>/<default-branch>`
   (always default branch; no stack)
4. **`git-pr`** — one PR; `git-closes` before `Closes`/`Fixes`; push to
   **push-remote** from the remote map

### 4. Done

Report PR URL, deferred issues (or none), and remotes used
(`base-remote` / `push-remote`).

## Related skills

- `git-pipeline` — batch + stacking
- `git-worktree` — remotes + isolation
- `git-assess`, `git-plan`, `git-implement`, `git-pr` — phases
- `git-sandbox`, `git-closes`
