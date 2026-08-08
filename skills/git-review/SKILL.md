---
name: git-review
description: >-
  Review branch or PR changes against the project's architecture service
  contracts. Discovers docs/architecture/service-contracts.md (or
  architecture.contracts in .git-pipeline.yml), classifies changed files by
  layer, runs hard/soft checks, and reports a severity-sorted verdict. Use
  when reviewing architecture, checking layer contracts, or from git-implement
  / git-pr architecture angles. If contracts are missing, offers to scaffold
  them before reviewing.
license: Apache-2.0
compatibility: >-
  Agentskills.io clients (Cursor, Claude Code, …). Optional Lola install.
metadata:
  author: Leonardo Gallego
  version: "1.0.0"
  collection: workflow
---

# git-review

## Overview

Architecture **contract** review procedure. Project rules live in the repo’s
service contracts (and optional ADR/strategy docs) — not in this skill.
Companions (PEP8, Kotlin, …) come from assess `skills_needed` /
`always_load_review_skills`. Templates: [report-format.md](report-format.md),
[contracts-template.md](contracts-template.md).

(Pack design notes live in repo-root `GIT_REVIEW_SPEC.md` when developing
this pack — do not require that file at review time.)

## When to use / not

**Use when:** reviewing architecture / layer contracts; `git-implement` or
`git-pr` architecture angle; user asks to check contracts on a branch/PR.

**Not when:** opening/merging PRs (`git-pr`); line-level style (stack skills);
deep security audit (`security-review` / security angle); plan-only review
unless the user explicitly asks (`git-plan` notes missing contracts — does not
force bootstrap).

## Instructions

### 0. Resolve contracts

Resolution order:

1. `.git-pipeline.yml` → `architecture.contracts` if set and file exists
2. Else `docs/architecture/service-contracts.md` if exists
3. Else exactly one `docs/**/service-contracts.md` → use it; if many → ask
4. Else → **bootstrap** (§1). Do not review. Never report `Clean`.

Treat as **missing** (same bootstrap) when the resolved file is empty or only
scaffold TODOs with no real layer map / hard rules — unless the user says to
treat a fresh scaffold as intentional and skip review for now.

If a usable contracts file exists but yaml has no `architecture.contracts`:
proceed, then optionally Info-suggest adding the key +
`always_load_review_skills: [git-review]`.

Load optional paths when present: `architecture.adr_dir`,
`architecture.strategy`, `architecture.provider` (see conventions).

### 1. Bootstrap (contracts missing or empty stub)

**STOP.** Offer:

```text
No architecture contracts found at <tried-paths>.
I can scaffold:
  - docs/architecture/service-contracts.md  (from contracts-template.md)
  - .git-pipeline.yml → architecture.contracts (+ always_load_review_skills)
Proceed? (yes / different path / skip review)
```

| Answer | Action |
|--------|--------|
| **yes** | Write [contracts-template.md](contracts-template.md) to the path; create/update `.git-pipeline.yml` keys; show files; invite fill-in. Optional **after** yes: draft layer-map rows from source layout — mark as draft, not policy. Then ask whether to review now or wait. |
| **different path** | Use user path; if still missing, re-offer scaffold there. |
| **skip review** | Return verdict `Skipped — no contracts`. Caller may continue other angles. |

Never invent hard rules as enforceable policy without confirmation.

### 2. Target and diff

1. Target: `$ARGUMENTS` (PR number/URL/branch) or current branch vs default.
2. Base: session default from `git-worktree` / conventions, else discover.
3. Diff: `git diff <base>...HEAD` (name-only + content as needed). Open PR →
   forge provider via `git-sandbox`.
4. Skip obvious non-code noise (lockfiles, generated) unless contracts say
   otherwise.

### 3. Load SoT and classify

1. Read contracts in full. If the PR edits contracts, review those edits first.
2. Classify each changed file with the contracts’ **Layer map**. Unmapped →
   Info or skip per contracts guidance.
3. Load companion skills from assess `skills_needed` /
   `always_load_review_skills` when in the local index — do not hardcode
   unrelated packs (`git-assess` §5).

### 4. Hard and soft checks

- **Hard:** every applicable hard rule in contracts → Error / must-fix.
- **Soft:** guidelines (size, naming, extraction, pattern drift) → Warning /
  consider.
- Judge only against contracts + loaded companions for *this* stack. Do not
  invent cross-ecosystem rules.

Medium/large diffs may use parallel subagents (layers, API/types,
concurrency/state, security-at-boundary, ADR/strategy), then synthesize.

### 5. Report

Emit [report-format.md](report-format.md). Per-finding severity + rollup
verdict: `Clean` | `Fixable` | `Needs architecture discussion` |
`Skipped — no contracts`.

When called from `git-implement` / `git-pr` multi-angle review, **also** emit
a Finding list for the fix loop (same shape as `reviewer-prompt.md`):

```text
Finding:
  severity: critical | warning | info
  file: <path>
  line: <n or range>
  rule: "<contracts cite>"
  description: "…"
  suggestion: "…"
```

Map: Error/must-fix → `critical`; Warning/consider → `warning`; Info → `info`.
Include one Finding or summary line for the Verdict when useful
(`rule: "git-review verdict"`).

### 6. Self-update hint

If the PR changes contracts, ADRs, layer map, or documented exceptions → Info:
update **contracts** (and yaml if paths moved), not this skill.

## Failure modes

| Situation | Action |
|-----------|--------|
| No contracts | Bootstrap; never `Clean` |
| Ambiguous multiple `service-contracts.md` | Ask user |
| Contracts are empty TODO stub only | Same as missing → bootstrap (§1); never claim full coverage |
| `git-review` not in index mid-pipeline | Caller falls back to `reviewer-prompt.md` architecture checklist |

## Related skills

- `git-implement`, `git-pr` — callers for architecture angle
- `git-assess` — `skills_needed` / always-load
- `git-pipeline` conventions / foundation — `architecture.*` keys
- `git-sandbox` — forge PR diff when needed
- `git-plan` — notes missing contracts; does not force bootstrap
