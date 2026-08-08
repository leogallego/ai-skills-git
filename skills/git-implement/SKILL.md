---
name: git-implement
description: >-
  Implement an issue plan in an isolated worktree: call git-worktree with
  base= and branch=, code against the plan, run tests/linters, code-review, and
  fix. Use from git-issue or git-pipeline after assess (and plan when required).
license: Apache-2.0
compatibility: >-
  Agentskills.io clients (Cursor, Claude Code, …). Optional Lola install.
metadata:
  author: Leonardo Gallego
  version: "0.1.0"
  collection: workflow
---

# git-implement

## Overview

Phase skill: execution. **Stub (M1).** M2 ports implementer/reviewer prompts
and review angles. Isolation is **only** via `git-worktree` (no inline
worktree procedure).

## When to use / not

**Use when:** called from an entry with issue brief/plan and assigned `branch=` /
`base=`.

**Not when:** planning only → `git-plan`; shipping PR → `git-pr`.

## Instructions (contract)

1. Confirm remote map exists (`git-worktree` §0); run it if missing.
2. Follow `git-worktree` with caller `branch=` and `base=` (required isolation).
3. Implement per plan (or assess brief on fast path). Subagents must not push
   (`git-sandbox`).
4. Tests/linters from project conventions; code review per scope matrix (M2).
5. Fix findings; leave commits ready for `git-pr` on **push-remote**.

## Related skills

- `git-worktree` — remotes + isolation (required)
- `git-pr` — next phase
- `git-sandbox` — no subagent push
- `git-issue`, `git-pipeline` — callers
