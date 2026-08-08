# Issue prompt template

Paste below the process skill (or say “follow git-issue”) and fill every field.

```text
Repo: <owner/repo or local path>
Base: origin/main   # or origin/<default-branch>
Branch: <type>/<n>-<slug>
Issue: https://github.com/<owner>/<repo>/issues/<n>
Canonical / ADRs: <paths or links, or "none">

Goal
<what done looks like — one short paragraph or bullets>

Out of scope: <explicit non-goals; adjacent issues other agents own>

Tests:
  <exact commands, e.g. pytest … -k '…' -q>
  <exact lint, e.g. ruff check <paths>>

Done: PR <title> — Closes #<n>
  # or "Partial progress on #<n>" if the issue will remain open
Architecture / quality reviews clean (or deferred items listed with issue links).
Independent of <parallel agents / issues, or "none">.
```

If only `git-issue` was named and this block is missing, the agent must STOP and
ask for these fields — not invent scope.
