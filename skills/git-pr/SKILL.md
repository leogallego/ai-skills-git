---
name: git-pr
description: >-
  Open and manage one pull request for an issue branch: push to the verified
  push-remote, PR body with git-closes, optional PR review comments, partial
  progress wording, and single-PR merge mechanics including merge-via-API.
  Use from git-issue or git-pipeline after git-implement.
license: Apache-2.0
compatibility: >-
  Agentskills.io clients (Cursor, Claude Code, …). Optional Lola install.
metadata:
  author: Leonardo Gallego
  version: "0.1.0"
  collection: workflow
---

# git-pr

## Overview

Phase skill: one PR. **Stub (M1).** M2 ports PR body/review-summary templates
and full merge flows. Multi-PR sequencing stays in `git-pipeline`.

## When to use / not

**Use when:** branch is ready to publish or merge one PR.

**Not when:** choosing remotes/worktrees → `git-worktree`; batch merge order →
`git-pipeline`.

## Instructions (contract)

1. Use session **push-remote** / **base-remote** from `git-worktree` §0 — never
   assume `origin`. Push: `git push -u <push-remote> HEAD`.
2. Load `git-closes` before any `Closes` / `Fixes`.
3. Open PR: head = push remote branch; base = canonical default (or stack
   parent when `git-pipeline` says so). Tool choice via `git-sandbox`.
4. Partial progress: no close keywords; update issue checklist; link deferrals.
5. Single-PR merge when asked: prefer `gh`/MCP; if default branch is checked
   out elsewhere, merge via API — do not reset the primary checkout.
6. Optional PR review comments (M2 templates).

## Related skills

- `git-closes` — verify issue numbers
- `git-sandbox` — push/API tooling
- `git-worktree` — remote map
- `git-issue`, `git-pipeline` — callers
