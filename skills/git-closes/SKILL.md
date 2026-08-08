---
name: git-closes
description: >-
  Verify GitHub issue numbers before using Closes or Fixes in commits or pull
  requests. Use when drafting PR bodies, commit trailers, or any text that would
  auto-close an issue; when issue numbers come from plans, specs, or memory.
license: Apache-2.0
compatibility: >-
  Agentskills.io clients (Cursor, Claude Code, …). Optional Lola install.
metadata:
  author: Leonardo Gallego
  version: "1.0.0"
  collection: hygiene
---

# git-closes

## Overview

Wrong `Closes #N` / `Fixes #N` auto-closes unrelated work. Always confirm the
issue number against the live tracker before using those keywords.

## When to use / not

**Use when:** writing a PR description, commit message, or merge text that
references closing an issue; numbers came from a plan, handoff, or chat.

**Not when:** linking an issue for context only without close keywords (still
prefer a real URL). Partial progress PRs should not use `Closes` — see
`git-issue`.

## Instructions

1. Read the candidate number from the issue prompt, plan, or user message.
2. Resolve the issue via API (GitHub MCP `issue_read` / `search_issues`, or
   `gh issue view <n>` when auth works):
   - Exists in the intended `owner/repo`
   - State is open (unless the user explicitly wants to close a different open
     issue — still confirm title/body match the work)
   - Title/topic matches the change you actually made
3. If mismatch or ambiguity: **STOP** and ask the user. Do not guess.
4. Only then use `Closes #<n>` or `Fixes #<n>`.
5. For incomplete work: omit close keywords; write `Partial progress on #<n>`
   and update the issue checklist (`git-issue`).

## Failure modes

| Risk | Mitigation |
|------|------------|
| Stale number in a plan file | Always re-read the issue via API |
| Same number, different repo | Check `owner/repo` |
| Close on partial PR | Use partial-progress wording instead |

## Related skills

- `git-issue` — when Closes vs partial progress applies
- `git-sandbox` — API access when `gh` is broken in sandbox
