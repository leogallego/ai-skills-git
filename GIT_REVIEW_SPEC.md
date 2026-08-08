# Spec: `git-review` — architecture contract review

**Status:** Implemented on branch `feat/git-review` (worktree) — not merged  
**Date:** 2026-08-08  
**Audience:** Maintainers / review before merge  
**Branch / worktree:** `feat/git-review` → `.worktrees/feat-git-review`  
**Related:** `PIPELINE_PLAN.md`, `skills/git-review/`,  
`skills/git-implement/reviewer-prompt.md`,  
`skills/git-pipeline/conventions.md`, `skills/git-pipeline/foundation.md`

**Process note:** First pass was wrongly edited on primary `main`; WIP was
stashed and moved into this worktree. Spec should be re-read before further
feature work (see §15 gap review).

---

## 1. Problem

Product repos (e.g. ansible-know-mcp, Ansible Jane) each maintain a fat
`skills/pr-architecture-review/SKILL.md` that duplicates:

- a shared review **procedure** (diff → layer classify → hard/soft checks → report)
- project **substance** that already belongs in `docs/architecture/service-contracts.md`

That causes dual SoT drift and “new skill per project” churn. The git pack
already has the workflow hooks (`git-implement` / `git-pr` review angles,
foundation architecture discovery, `always_load_review_skills`) but no thin,
named skill that owns the architecture-review **procedure**.

## 2. Goals

1. Add a portable phase skill **`git-review`** that orchestrates architecture
   contract review against **discovered project contracts** — no embedded
   layer maps, DI rules, or stack checklists.
2. Extend `.git-pipeline.yml` with optional `architecture.*` keys for
   discovery (same style as `forge.provider` / `always_load_review_skills`).
3. Wire `git-implement` and `git-pr` so the architecture angle prefers
   `git-review` when present.
4. **Bootstrap path:** if contracts (and optional yaml keys) are missing when
   the skill is invoked, **stop and offer to scaffold them** before reviewing —
   never invent silent “architecture” for the repo.
5. Document a minimal **contracts template** so product repos can migrate off
   fat `pr-architecture-review` skills (migration itself is out of scope for
   the implementing session unless the user asks).

## 3. Non-goals

- New pack / new repo (`ai-skills-architecture`, etc.)
- Skill name `git-pr-review` (review also runs at plan/implement; `git-pr`
  owns forge PR lifecycle)
- Embedding Python/Kotlin/Android/MCP project rules in this pack
- Replacing `pep8-*`, kotlin companion skills, or Bugbot / security-review
- Auto-writing contracts without user confirmation
- CI / static import-graph enforcement

## 4. Why this pack (scope fit)

| In scope for `ai-skills-git` | Out of scope |
|------------------------------|--------------|
| Review **procedure** as a phase skill | Product layer maps / exceptions |
| Discover contracts via conventions | ADR strategy substance |
| Bootstrap / first-run scaffold offer | Stack style (PEP8, Compose, …) |
| Wire into implement / pr review | Per-repo `pr-architecture-review` content |

Same pattern as `git-sandbox` + forge providers: shared skill + project SoT
file. Name follows `git-<concern>` → **`git-review`**.

---

## 5. Bootstrap: missing contracts — yes, offer to create first

**Decision: yes — this should work, and it should be a hard pause.**

When `git-review` is invoked (standalone or from implement/pr):

1. Resolve contracts path (see §6).
2. If the contracts file **does not exist** (or is empty / clearly a stub),
   **do not review**. Present a short offer:

   ```text
   No architecture contracts found at <path>.
   I can scaffold:
     - docs/architecture/service-contracts.md  (from pack template)
     - .git-pipeline.yml architecture.contracts key (+ always_load_review_skills)
   Proceed? (yes / different path / skip review)
   ```

3. On **yes**: write the template (§8), add/update yaml keys (§6), show the
   user what was created, and ask them to fill layer map + hard rules
   (or offer a **read-only draft** inferred from the repo — see below).
4. On **skip**: return verdict `Skipped — no contracts` and stop architecture
   angle only (other review angles may continue if the caller is multi-angle).
5. Never treat a missing contracts file as “Clean”.

### Optional draft assist (after user says yes)

Allowed **after** confirmation, marked clearly as draft:

- Infer stack from manifests (already in foundation)
- Propose layer names from top-level source layout (`src/`, `shared/`, …)
- Leave hard rules / exceptions as TODO checkboxes

Do **not** invent hard rules as if they were policy. Prefer:

> Draft inferred from layout — confirm or edit before treating as enforceable.

This mirrors `git-pipeline` conventions first-run (infer → confirm → save),
not silent generation.

### When yaml keys are missing but contracts exist

If `docs/architecture/service-contracts.md` (or discovered path) exists but
`.git-pipeline.yml` has no `architecture.contracts`:

- Proceed with discovery defaults.
- Optionally offer (non-blocking Info): add `architecture.contracts` +
  `always_load_review_skills: [git-review]` for faster future loads.

Do **not** block review solely for missing yaml if contracts file is present.

---

## 6. Configuration (`.git-pipeline.yml`)

Extend conventions suggested keys (document in
`skills/git-pipeline/conventions.md`):

```yaml
always_load_review_skills:
  - git-review          # procedure (this pack)
  # - pep8-review       # stack companions still listed separately

architecture:
  # Path to enforceable contracts (SoT). Default discovery if omitted:
  #   docs/architecture/service-contracts.md
  contracts: docs/architecture/service-contracts.md
  # Optional extras (load when present; do not require):
  adr_dir: docs/architecture/adr/
  strategy: docs/architecture/project-strategy.md
  # Optional thin provider (layer map / companion skill table only).
  # Prefer putting the layer map inside contracts; use provider only when
  # contracts would become unreadable.
  # provider: docs/architecture/review-provider.md
```

**Resolution order for contracts path:**

1. `.git-pipeline.yml` → `architecture.contracts` if set and file exists  
2. Else `docs/architecture/service-contracts.md` if exists  
3. Else glob `**/service-contracts.md` under `docs/` (if exactly one hit, use it;
   if many, ask user)  
4. Else → **bootstrap offer** (§5)

---

## 7. Skill design: `skills/git-review/`

### Layout

```text
skills/git-review/
├── SKILL.md                 # procedure (normative)
├── report-format.md         # output template
└── contracts-template.md    # scaffold body for bootstrap
```

Keep `SKILL.md` under ~200 lines. No product-specific checklists.

### Frontmatter (draft)

```yaml
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
```

### Procedure (normative outline for SKILL.md)

**When to use / not**

- Use: architecture / contracts / layer review; implement/pr architecture angle
- Not: line-level style (stack skills), deep security audit, forge PR open/merge
  (`git-pr`), plan-only review (`git-plan` may still call this against a plan’s
  proposed file touch list — optional follow-up)

**Steps**

0. **Resolve contracts** (§6). Missing → bootstrap (§5). Stop until resolved
   or user skips.
1. **Target:** `$ARGUMENTS` PR number/URL/branch, else current branch vs
   default branch (`git-worktree` remote map if present; else discover default).
2. **Diff:** `git diff <base>...HEAD` (name-only + full as needed). For open
   PRs, forge provider via `git-sandbox` is OK. Skip non-code noise
   (README-only, lockfiles) unless contracts say otherwise.
3. **Load SoT:** read contracts in full; if the PR itself changes contracts,
   review those edits for coherence first. Load ADR/strategy/provider only
   when paths exist.
4. **Classify** changed files by layer using the contracts’ layer map section.
   Unmapped paths → note Info or skip per contracts guidance.
5. **Companions:** load skills from assess `skills_needed` /
   `always_load_review_skills` that are stack-relevant — do not hardcode pack
   names beyond discovering the local index (same rule as `git-assess`).
6. **Hard checks:** every hard rule in contracts that applies to changed files.
   Must-fix.
7. **Soft checks:** guidelines / size / naming drift. Consider / Warning.
8. **Report** via `report-format.md`. Verdict one of:
   - `Clean`
   - `Fixable` (N hard, M soft)
   - `Needs architecture discussion` (structural / contracts change / unclear)
   - `Skipped — no contracts` (bootstrap declined)
9. **Self-update hint:** if the PR changes contracts, ADRs, layer map, or
   documented exceptions → Info finding: update **contracts** (and yaml if
   paths moved), not `git-review`.

**Parallel dimensions (optional):** for medium/large diffs, may dispatch
subagents (layers, API/types, concurrency/state, security-at-boundary,
ADR/strategy) that each receive the contracts excerpts + their slice of the
diff — then synthesize. Not required for trivial/small.

**Severity**

| Level | Meaning |
|-------|---------|
| Error / must-fix | Hard rule violation — block merge for architecture angle |
| Warning / consider | Soft guideline or fix-or-file-issue |
| Info | Note, draft contracts, self-update hint |

Reuse language already in `reviewer-prompt.md` architecture angle where
possible; prefer **pointer** from that prompt to `git-review` rather than
duplicating long checklists.

---

## 8. Contracts template (`contracts-template.md`)

Scaffold used by bootstrap. Keep sections stable so `git-review` can teach
agents where to look:

```markdown
# Architecture Service Contracts

Enforceable rules for this repository. Reviewed by `git-review`
(ai-skills-git). Hard rules must be fixed before merge. Soft guidelines are
advisory.

## Layer map

| Path / pattern | Layer |
|----------------|-------|
| TODO           | TODO  |

## Dependency rules

- Higher layers may depend on lower layers only.
- TODO: list allowed edges and forbidden shortcuts.

## Hard rules

- [ ] TODO (imports, module boundaries, DI, state exposure, secrets, …)

## Soft guidelines

- [ ] TODO (file size, naming, extraction signals, …)

## Known exceptions

| ID | Summary | Status |
|----|---------|--------|
| —  | —       | —      |

## Companion skills (optional)

| When files match | Load skill (if installed) |
|------------------|---------------------------|
| TODO             | TODO                      |
```

Product repos may expand freely; `git-review` must not require more than
layer map + hard/soft sections.

---

## 9. Integration points (this repo)

| File | Change |
|------|--------|
| `skills/git-review/*` | **New** |
| `skills/git-pipeline/conventions.md` | Document `architecture.*` keys; example `always_load_review_skills: [git-review]` |
| `skills/git-pipeline/foundation.md` | Prefer `architecture.contracts` when listing architecture docs |
| `skills/git-implement/SKILL.md` | Architecture angle: load/follow `git-review` when in skill index |
| `skills/git-implement/reviewer-prompt.md` | Architecture section: “Follow `git-review` if loaded; else existing checklist against foundation contracts” |
| `skills/git-pr/SKILL.md` §6 | Same — architecture via `git-review` when available |
| `skills/git-plan/plan-reviewer-prompt.md` | Optional one-liner: if contracts missing, note N/A or suggest scaffold (do not force bootstrap during plan unless user asks) |
| `README.md` / `AGENTS.md` / `CONTRIBUTING.md` | List `git-review` in skills table + ownership |
| `scripts/validate-skills.sh` | Should pick up new skill automatically if it scans `skills/*` |

**Dedup rule:** long architecture checklist text should live once — either in
`git-review` or in `reviewer-prompt.md`, with the other pointing. Prefer
normative procedure in `git-review`, short fallback in `reviewer-prompt.md`
when `git-review` is not installed.

---

## 10. Product-repo migration (out of scope for implement session)

Document for later (do not edit sibling repos from the `ai-skills-git` session
unless the user explicitly opens those roots):

1. Ensure `docs/architecture/service-contracts.md` contains layer map + hard
   rules currently duplicated in `skills/pr-architecture-review/SKILL.md`.
2. Add yaml keys; set `always_load_review_skills` to include `git-review`.
3. Delete or replace project `pr-architecture-review` with a stub pointing at
   `git-review` + contracts (prefer delete once pipeline works).
4. Keep stack companions (pep8, kotlin-*, …) as separate always-load / assess
   matches.

Known candidates: ansible-know-mcp, remote-aap (Ansible Jane).

---

## 11. Implementation checklist

Work only under `ai-skills-git`:

- [x] Add `skills/git-review/SKILL.md` per §7
- [x] Add `skills/git-review/report-format.md`
- [x] Add `skills/git-review/contracts-template.md` per §8
- [x] Update `conventions.md` + `foundation.md` for `architecture.*`
- [x] Wire `git-implement` + `reviewer-prompt.md` + `git-pr` §6
- [x] Update README / AGENTS / CONTRIBUTING ownership tables
- [x] Run `./scripts/validate-skills.sh` (11 skills OK)
- [ ] Commit on a feature branch (user asks for commit/PR as usual)

Suggested commit message theme: add `git-review` phase skill with contracts
discovery and bootstrap scaffold offer.

---

## 12. Acceptance criteria

1. `git-review` validates with agentskills / pack validate script.
2. With contracts present: skill produces structured report + verdict without
   requiring a project `pr-architecture-review` skill.
3. With contracts **absent**: skill offers scaffold; does not claim `Clean`;
   on yes, writes template + yaml keys; on skip, returns `Skipped — no contracts`.
4. No Jane/know-specific paths or rules appear in the pack.
5. `git-implement` / `git-pr` docs reference `git-review` for architecture.
6. Pack stays installable via existing Cursor / Lola / plugin paths.

---

## 13. Open questions (resolve during implement if needed)

1. **Plan phase:** Should `git-plan` auto-call bootstrap, or only note missing
   contracts? **Default:** note only; bootstrap on explicit `git-review` /
   implement architecture angle.
2. **Provider file:** Ship as optional; prefer layer map inside contracts for v1.
3. **Verdict naming:** Align with Jane (`Clean` / `Fixable` / `Needs
   architecture review`) vs Error/Warning/Info only — **recommend both**:
   per-finding severity + rollup verdict string in `report-format.md`.

---

## 14. Handoff blurb (paste into the implement session)

```text
Implement GIT_REVIEW_SPEC.md in this repo (ai-skills-git only).

Add skills/git-review/ as a thin architecture-contract review orchestrator:
discover docs/architecture/service-contracts.md or architecture.contracts in
.git-pipeline.yml; classify diff by layer map in that doc; hard/soft checks;
structured report. If contracts are missing, STOP and offer to scaffold
contracts-template.md + yaml keys (confirm first; optional draft inference
after yes). Wire git-implement / git-pr architecture angles to git-review.
Do not embed product-repo rules. Do not edit sibling repos. Validate with
./scripts/validate-skills.sh. Do not commit unless I ask.
```

---

## 15. Post-implement gap review (2026-08-08)

Honest: implement ran before a disciplined spec pass, and initially on primary
`main` without a worktree. After isolation + re-read:

| Spec item | Status |
|-----------|--------|
| §7 layout + frontmatter | OK |
| §5 bootstrap offer + skip verdict | OK; empty/stub now treated as missing |
| §6 `architecture.*` in conventions | OK |
| §9 wiring implement/pr/plan/docs | OK |
| §12 validate | OK (11 skills) |
| No product-repo rules in pack | OK |
| SKILL link to pack-root spec | Fixed — removed install-breaking `../../GIT_REVIEW_SPEC.md` |
| reviewer-prompt hardcodes `skills/git-review/` path | Fixed — “follow git-review SKILL.md” |
| Worktree / feature branch | Fixed — `feat/git-review` under `.worktrees/` |
| Severity / Finding bridge (gaps 1–2) | Fixed — Error→critical mapping + dual output |
| Commit / PR | Pending user ask |
| Product-repo migration (§10) | Still out of scope |

Residual:

- Architecture fallback checklist when `git-review` absent →
  [#20](https://github.com/leogallego/ai-skills-git/issues/20).
- Dogfood contracts for this pack → **added**
  `docs/architecture/service-contracts.md` + `.git-pipeline.yml`.
- Install: prefer `scripts/install-agents.sh` → `~/.agents/skills/` (cross-client);
  `install-cursor.sh` is a wrapper. Re-run once after new skill dirs appear.
- Parallel dimension dispatch is documented optional only (per spec).
