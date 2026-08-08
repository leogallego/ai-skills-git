---
name: git-pr
description: >-
  Open and manage one pull request: push to verified push-remote, PR body with
  git-closes or partial-progress wording, PR review comments, deferred issues,
  and single-PR merge including merge-via-API. Use from git-issue or
  git-pipeline after git-implement.
license: Apache-2.0
compatibility: >-
  Agentskills.io clients (Cursor, Claude Code, …). Optional Lola install.
metadata:
  author: Leonardo Gallego
  version: "1.0.0"
  collection: workflow
---

# git-pr

## Overview

One PR lifecycle. Multi-PR merge order stays in `git-pipeline`. Adapted from
`issue-pipeline-skill` Phases 8–10 (+ single merge). Templates:
[pr-body.md](pr-body.md), [review-summary.md](review-summary.md).

## Instructions

### 1. Remotes

Use session **push-remote** / **base-remote** from `git-worktree` §0. Never
assume `origin`.

```bash
git push -u <push-remote> HEAD
```

(`git-sandbox` for tool/auth constraints.)

### 2. Commit remaining changes

Conventional commits; attribution from project / `.git-pipeline.yml`. SSH sign
per `git-sandbox`.

### 3. Open PR

- **Base branch:** default branch on **base-remote** (standalone / first in
  chain), or previous issue branch when `git-pipeline` stacks.
- **Head:** current branch on **push-remote** (fork workflow supported).
- Title: `<type>: <description> (#NNN)`
- Body: [pr-body.md](pr-body.md). Set `{{closes_or_partial_line}}` after
  `git-closes`:
  - Complete → `Closes #N`
  - Partial → `Partial progress on #N` (no Closes); update issue checklist;
    link deferred issues
  - Never “Does not close #N” — GitHub still auto-closes (`git-closes`)

API via MCP/`gh` (`git-sandbox`).

### 4. Review summary comment

Post [review-summary.md](review-summary.md) on the PR.

### 5. Issue trail

Comment with PR link. Labels (if enabled): remove `pipeline/in-progress`, add
`pipeline/awaiting-merge`.

### 6. PR review (optional / medium+)

Same angles as `git-implement` review on the GitHub PR diff. Fix-now vs file
follow-up issues (link in PR). Circuit breaker after 3 non-converging loops →
report failure to caller.

### 7. Single-PR merge (when asked)

Wait for required CI green + mergeable. Prefer MCP/`gh` merge with method from
`.git-pipeline.yml` (else detect, else `merge`). Delete remote feature branch
when appropriate.

If merge fails because the default branch is checked out in another worktree:
**merge via API** — do not checkout/reset the primary repo.

Confirm merged state via API. Sync local default only in a safe worktree.

### 8. Cleanup (no PR / skip / fail)

Caller may ask to remove the worktree; if PR exists, keep worktree until merge
(`git-pipeline` sequential cleanup).

## Related skills

- `git-closes`, `git-sandbox`, `git-worktree`
- `git-implement` — prior phase
- `git-issue`, `git-pipeline` — callers
