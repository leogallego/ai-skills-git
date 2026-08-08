---
name: git-implement
description: >-
  Implement an issue plan in an isolated worktree: call git-worktree with
  base= and branch=, code against the plan, run tests/linters, multi-angle
  code review, and fix. Use from git-issue or git-pipeline after assess (and
  plan when required).
license: Apache-2.0
compatibility: >-
  Agentskills.io clients (Cursor, Claude Code, …). Optional Lola install.
metadata:
  author: Leonardo Gallego
  version: "1.0.0"
  collection: workflow
---

# git-implement

## Overview

Execution phase. Isolation **only** via `git-worktree` (no inline worktree
steps). Adapted from `issue-pipeline-skill` Phases 5–7.

Prompts: [implementer-prompt.md](implementer-prompt.md),
[reviewer-prompt.md](reviewer-prompt.md).

## Instructions

### 1. Remotes + worktree

1. Ensure remote map exists (`git-worktree` §0).
2. Follow `git-worktree` with caller `branch=` and `base=` — **required**
   isolation. `git-issue`: base = `<base-remote>/<default>`. `git-pipeline`
   chain: later issues use previous issue branch as `base=`.

### 2. Implement

- Fast path (no plan): implement from assess `brief` + acceptance criteria.
- With plan: dispatch implementer using `implementer-prompt.md` (single
  subagent for trivial/small; optional parallel units for medium/large **in
  the same worktree**).
- Subagents **must not push** (`git-sandbox`).
- Respect `out_of_scope`. Sign commits (SSH in sandbox).

### 3. Tests and linters

Use commands from foundation/conventions (discover; do not hardcode). Retry
fix loop max 2; then fail/skip for caller.

### 4. Implementation review

Diff since merge-base with `base=`.

| Scope | Angles |
|-------|--------|
| trivial / small | architecture + code-quality |
| medium / large | architecture, code-quality, security, skill-compliance |

Use `reviewer-prompt.md` per angle. Aggregate findings (critical → must fix;
warnings → fix or justify; info → note).

### 5. Fix

Address criticals; fix or justify warnings (deferrals → issues). Re-test;
targeted re-review of angles that had criticals (max 2 attempts). No scope
expansion.

### 6. Handoff

Branch ready for `git-pr` on **push-remote**.

## Related skills

- `git-worktree`, `git-pr`, `git-sandbox`
- `git-assess`, `git-plan`
- `git-issue`, `git-pipeline`
