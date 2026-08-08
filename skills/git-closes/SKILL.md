---
name: git-closes
description: >-
  Verify GitHub issue numbers before using Closes or Fixes in commits or pull
  requests, and avoid wording that still auto-closes (e.g. “Does not close #N”).
  Use when drafting PR bodies, commit trailers, or any text that would
  auto-close an issue; when issue numbers come from plans, specs, or memory.
license: Apache-2.0
compatibility: >-
  Agentskills.io clients (Cursor, Claude Code, …). Optional Lola install.
metadata:
  author: Leonardo Gallego
  version: "1.1.0"
  collection: hygiene
---

# git-closes

## Overview

Wrong `Closes #N` / `Fixes #N` auto-closes unrelated work. Always confirm the
issue number against the live tracker before using those keywords.

GitHub also auto-closes when a **closing keyword** appears next to `#N` even
inside negation. Example incident: a PR said “Does not close #117” and still
closed `#117` on merge (substring match on `close #117`).

## When to use / not

**Use when:** writing a PR description, commit message, or merge text that
references closing an issue; numbers came from a plan, handoff, or chat;
choosing safe wording so a mention does **not** close an issue.

**Not when:** linking an issue for context only without close keywords (still
prefer a real URL or a safe phrase below). Partial progress PRs should not use
`Closes` — see `git-issue`.

## Closing keywords (GitHub)

GitHub treats these (and tense variants) as closers when followed by an issue
reference such as `#N` or a full issue URL — see [Linking a pull request to an
issue](https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/linking-a-pull-request-to-an-issue):

- `close`, `closes`, `closed`
- `fix`, `fixes`, `fixed`
- `resolve`, `resolves`, `resolved`

**Negation does not disable the match.** Do not write “does not close #N”.

## Safe vs unsafe wording

| Intent | Avoid (still closes) | Prefer |
|--------|----------------------|--------|
| Explicitly not closing | Does not close #N · won't close #N · not closing #N · doesn't fix #N · will not resolve #N | Related to #N · See #N · Part of #N · out of scope for #N |
| Partial / incomplete work | Closes #N · Fixes #N | Partial progress on #N |
| Intentional close (verified) | — | Closes #N or Fixes #N only after live verify below |
| Context-only link | close/fix/resolve on the same phrase as #N | Full issue URL on its own line, or See #N / Related to #N |

Optional escape when you must mention a number near those verbs: write
“issue N” **without** `#` and **without** a closing keyword adjacent (prefer
the table above; cite GitHub docs if relying on this).

Forge note: GitLab/Gitea/Forgejo close syntax may differ — see forge-portability
issues; this skill’s false-positive rules are written for **GitHub**.

## Instructions

1. Read the candidate number from the issue prompt, plan, or user message.
2. Resolve the issue via the active forge provider (`git-sandbox`; default
   GitHub MCP `issue_read` / `search_issues`, or `gh issue view <n>` when auth
   works):
   - Exists in the intended `owner/repo`
   - State is open (unless the user explicitly wants to close a different open
     issue — still confirm title/body match the work)
   - Title/topic matches the change you actually made
3. If mismatch or ambiguity: **STOP** and ask the user. Do not guess.
4. Only then use `Closes #<n>` or `Fixes #<n>`.
5. For incomplete work: omit close keywords; write `Partial progress on #<n>`
   and update the issue checklist (`git-issue`).
6. Before finalizing any PR/commit body: scan for closing keywords next to
   `#N` (including negated forms). Rewrite unsafe phrases using the table.

## Failure modes

| Risk | Mitigation |
|------|------------|
| Stale number in a plan file | Always re-read the issue via API |
| Same number, different repo | Check `owner/repo` |
| Close on partial PR | Use `Partial progress on #N` instead |
| “Does not close #N” still closes | Never negate a closing keyword; use Related to / See / Part of |

## Related skills

- `git-issue` — when Closes vs partial progress applies
- `git-pr` — PR body line after this skill
- `git-sandbox` — API access when `gh` is broken in sandbox
