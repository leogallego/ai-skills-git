---
name: git-plan
description: >-
  Write and review an implementation plan for a GitHub issue before coding.
  Use from git-issue or git-pipeline when assess scope is medium or large; skip
  for trivial/small fast path.
license: Apache-2.0
compatibility: >-
  Agentskills.io clients (Cursor, Claude Code, …). Optional Lola install.
metadata:
  author: Leonardo Gallego
  version: "0.1.0"
  collection: workflow
---

# git-plan

## Overview

Phase skill: plan + plan review. **Stub (M1).** M2 ports plan generation,
`plan-reviewer-prompt.md`, and plan path discovery (`docs/plans/` etc.).

## When to use / not

**Use when:** assess scope is medium/large.

**Not when:** trivial/small fast path → caller skips straight to `git-implement`.

## Instructions (contract)

1. Load skills listed by `git-assess`.
2. Write a file-by-file plan under a discovered plans directory (M2).
3. Run plan review (prompt in M2); revise until acceptable.
4. Hand plan path to `git-implement`.

## Related skills

- `git-assess` — prior phase
- `git-implement` — next phase
- `git-issue`, `git-pipeline` — callers
