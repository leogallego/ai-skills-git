---
name: git-assess
description: >-
  Assess a GitHub issue against the current codebase: re-read issue payload,
  verify references, estimate scope, map skills, record out-of-scope exclusions,
  and optionally comment/label. Use during git-issue or git-pipeline after
  remotes are verified and an issue payload exists (or fetch if missing).
license: Apache-2.0
compatibility: >-
  Agentskills.io clients (Cursor, Claude Code, …). Optional Lola install.
metadata:
  author: Leonardo Gallego
  version: "0.1.0"
  collection: workflow
---

# git-assess

## Overview

Phase skill: analysis only. **Does not** create worktrees or PRs.

**Stub (M1):** contract only. Port assess/update-issue content in M2
(`assessment-comment` template, scope table, skill mapping).

## When to use / not

**Use when:** called from `git-issue` / `git-pipeline` with an issue number or
payload.

**Not when:** user only wants remotes/worktree setup → `git-worktree`.

## Instructions (contract)

1. Prefer the issue payload from the entry. If missing, fetch via `git-sandbox`
   tool rules (MCP/`gh`).
2. Confirm issue `owner/repo` still matches the session **base-remote** map
   from `git-worktree` §0; if remotes were not verified yet, run that first.
3. Re-read body; verify cited paths/APIs still exist; estimate scope
   (trivial/small/medium/large).
4. Map relevant project skills; list out-of-scope related issues.
5. Skip/stop if obsolete or already handled (caller decides labels/comments;
   M2 adds templates).
6. Return: scope, brief, exclusions, skill list, risk flags — for plan/implement.

## Related skills

- `git-issue`, `git-pipeline` — callers
- `git-plan`, `git-implement` — next phases
- `git-worktree` — remote map
- `git-sandbox` — API tool choice
