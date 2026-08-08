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
  version: "1.1.0"
  collection: workflow
---

# git-plan

## Overview

Plan + plan review before code. Adapted from `issue-pipeline-skill` Phases 3–4.

**Skip** when assess scope is trivial/small (fast path → `git-implement`).

## Instructions

### 1. Load skills

Read full `SKILL.md` for every name in assess `skills_needed` (already
filtered to the project stack — see `git-assess` skill mapping). Do **not**
load unrelated local skills.

### 2. Generate plan

If Superpowers `writing-plans` (or equivalent) is loaded, use it. Otherwise
cover:

- File-by-file changes (what/why/order)
- New files (purpose, location per project layout)
- Test strategy (commands/dirs from foundation/conventions)
- Build/CI changes if any
- Migration/compat — or explicit “No migration needed”

### 3. Save plan

Discover plans dir: existing `docs/**/plans/`, else `docs/plans/`.

```text
docs/plans/YYYY-MM-DD-issue-NNN-<slug>.md
```

Slug from title: lowercase, hyphens, max 40 chars.

### 4. Validate against assess

- Extra files: legitimate miss → update assess; overreach → trim plan
- Acceptance criteria covered?
- No work for `out_of_scope` issues

### 5. Large-issue decomposition

If large (15+ files / natural seams), **caller decides stacking**:

| Caller | Decomposition |
|--------|----------------|
| **`git-issue`** | **No stacked PRs.** One branch from `<base-remote>/<default-branch>`; sequential commits (and optional plan task list) in a **single** PR. If the user needs multiple PRs for one issue, stop and recommend `git-pipeline` (or split follow-up issues). |
| **`git-pipeline`** | May split into sequential tasks (internal stack): each task `branch=<type>/<n>-task-<T>-<slug>`, `base=` = previous task branch; intermediate PRs use `Part of #N` (safe wording — `git-closes`); last uses `Closes #N` after verify. Caller runs implement→pr per task and **merge retarget** (`git-pipeline` §6). |

### 6. Plan review

Dispatch reviewer with [plan-reviewer-prompt.md](plan-reviewer-prompt.md).
Finding format: severity, area, description, suggestion.

| Outcome | Action |
|---------|--------|
| Criticals | Revise plan; re-review (max 2 loops) |
| Warnings | Fix or justify in plan |
| Clean | Hand plan path to `git-implement` |

## Related skills

- `git-assess`, `git-implement`
- `git-issue`, `git-pipeline`
