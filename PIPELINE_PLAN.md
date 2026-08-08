# Pipeline migration plan

Migrate and rebuild [`issue-pipeline-skill`](../issue-pipeline-skill) into this pack as `git-*` skills. Two thin entry points share the same phase skills — no copied workflows.

**Status:** M3 complete — M4 source README pointed; M5 prove next  
**Source:** `~/Claude/issue-pipeline-skill` (Apache-2.0)  
**Target:** `~/Claude/ai-skills-git`

---

## Goals

1. **Single pack** for git/GitHub agent workflows.
2. **Number-first UX:**
   - `git-issue 123` — **one** issue, base = default branch (no stacking)
   - `git-pipeline #123 #456` — **many** issues, triage/DAG, **stacked** chains where deps require it
3. **Reuse pack skills:** phase skills + `git-worktree` / `git-sandbox` / `git-closes` / `git-ignore-ai`. Entry skills only orchestrate.
4. **Keep multi-agent hard stops** (primary checkout, branch verify, collision STOP, merge-via-API, partial progress / deferred issues).
5. **Slim the monolith** into thin orchestrators + phase skills + sibling prompts/templates.

## Non-goals

- Replacing Superpowers TDD/plans (optional peer if already loaded).
- Forgejo/GitLab first-class ports.
- Preserving every `issue-pipeline` quirk without review (old branch prefix, squash-only, Superpowers plan paths).

---

## Entry points (disambiguation)

| | `git-issue` | `git-pipeline` |
|--|-------------|----------------|
| Input | Exactly one issue number/URL | One or more (batch) |
| Ordering | None | Triage, deps DAG, chains |
| Worktree `base=` | Always `origin/<default>` | First in chain / standalone → default; later → **previous issue branch** |
| Merge | Single PR via `git-pr` | Merge gate + **sequential** merges + worktree cleanup |
| Conventions / foundation | Load (shared helpers) | Load + full triage |

**Duplication rule:** both entry skills are **thin**. They must not paste assess/plan/implement/PR procedures. They only sequence calls to `git-assess` → `git-plan` (if needed) → `git-implement` → `git-pr`. Shared normative text lives once in the phase skills.

If `git-pipeline` is invoked with a **single** issue and no deps: same phase sequence as `git-issue`, plus optional conventions bootstrap; stacking logic is a no-op. Prefer telling users: one issue → `git-issue`; batch/deps → `git-pipeline`.

---

## Target skill set

Naming rule: `git-<concern>` ([CONTRIBUTING.md](CONTRIBUTING.md)).

| Skill | Domain | Owns |
|-------|--------|------|
| **`git-issue`** | Orchestration (single) | One number → fetch that issue → phase loop → one PR; peer-agent stops; no DAG/stack |
| **`git-pipeline`** | Orchestration (batch) | Foundation/conventions; triage; per-issue phase loop; stack bases; merge gate; sequential merge; cleanup; run-state |
| **`git-assess`** | Analysis | Re-read / verify (use payload from entry if present; fetch if missing); scope; skill map; exclusions; comments/labels; skip if obsolete |
| **`git-plan`** | Planning | Plan file + plan review |
| **`git-implement`** | Execution | `git-worktree` + implement + code review + fix |
| **`git-pr`** | Shipping | One PR create/review/cleanup/merge mechanics; `git-closes` |
| `git-worktree` | Mechanics | Isolation; **`base=`** + **`branch=`** |
| `git-sandbox` | Environment | Tool routing only |
| `git-closes` | Hygiene | Verify before `Closes` / `Fixes` |
| `git-ignore-ai` | Hygiene | Optional if status noisy |

**Rewrite (not delete):** today’s `git-issue` + `prompt-template.md` → number-first thin orchestrator; delete the paste template.

```text
git-issue 123                    git-pipeline #1 #2 #3
    │                                  │
    │ fetch one                        │ foundation + conventions
    │                                  │ triage (fetch all, DAG, chains)
    ▼                                  ▼
    └──────────► git-assess ◄──────────┘
                      │
                      ▼
              git-plan (medium/large only)
                      │
                      ▼
              git-implement ──► git-worktree(base=…)
                      │
                      ▼
                   git-pr ──► git-closes, git-sandbox
                      │
        git-issue: done          git-pipeline: merge gate → sequential merge → cleanup
```

### Ownership (no shared normative text)

| Concern | Single owner |
|---------|----------------|
| Single-issue entry / no stack | `git-issue` |
| Batch entry / triage / stack / merge sequence | `git-pipeline` |
| Issue payload for assess | Entry fetches; `git-assess` re-reads + verifies (fetches only if payload missing) |
| Plan + plan review | `git-plan` |
| Worktree create/verify | `git-worktree` only |
| Implement + code review + fix | `git-implement` |
| One PR + Closes + single merge call | `git-pr` |
| Tool choice under sandbox | `git-sandbox` only |
| Peer-agent collision / partial progress / deferred issues | Entry policy (`git-issue` / `git-pipeline`) + wording in `git-pr` |
| Remote map (canonical vs fork / origin vs upstream) | **`git-worktree` §0** — entries run before any fetch/push |

---

## Source phases → target

| Phase | Name | Target |
|-------|------|--------|
| 0 | Triage (fetch batch, deps, DAG, chains) | `git-pipeline` + `triage-prompt.md` |
| 0 | Foundation context | `git-pipeline/foundation.md` (also linked from `git-issue` for light load) |
| 0 | Conventions | `git-pipeline/conventions.md` → `.git-pipeline.yml` (`git-issue` loads file if present; full infer/confirm is pipeline’s job) |
| 1–2 | Assess + update issue | `git-assess` |
| 3–4 | Plan + plan review | `git-plan` |
| 5–7 | Implement + review + fix | `git-implement` → `git-worktree` |
| 8–10 | PR + PR review + cleanup | `git-pr` |
| 11–12 | Merge gate + sequential merge + worktree prune | `git-pipeline` only |

### File migration map

| Source | Destination |
|--------|-------------|
| Batch orchestrator + Phase 0 loop | `skills/git-pipeline/SKILL.md` |
| Phase 0 Step 0 detail | `skills/git-pipeline/foundation.md` |
| Phase 0 Step 1 detail | `skills/git-pipeline/conventions.md` |
| `triage-prompt.md` | `skills/git-pipeline/triage-prompt.md` |
| Phases 1–2 + `templates/assessment-comment.md` | `skills/git-assess/` |
| Phases 3–4 + `plan-reviewer-prompt.md` | `skills/git-plan/` |
| Phases 5–7 + `implementer-prompt.md` + `reviewer-prompt.md` | `skills/git-implement/` (no inline worktree) |
| Phases 8–10 + `templates/pr-body.md` + `review-summary.md` | `skills/git-pr/` |
| `templates/completion-report.md` | `skills/git-pipeline/completion-report.md` |
| Current `git-issue` + `prompt-template.md` | Rewrite thin orchestrator; **delete** prompt-template |
| Inline worktree blocks in source | **Delete** → “follow `git-worktree`” |

---

## Locked defaults

| Topic | Decision |
|-------|----------|
| Entry points | **`git-issue`** = single; **`git-pipeline`** = batch + stacking |
| Stacked PRs | **In v1**, only via `git-pipeline` |
| Branch name | Pack default **`<type>/<n>-<slug>`** (type from labels / default `fix`); override in `.git-pipeline.yml` |
| Prompt template | Delete; assess builds brief from issue body |
| Config file | `.git-pipeline.yml` (read legacy `.issue-pipeline.yml` if present) |
| Worktree `base=` | `git-issue` → always default branch; `git-pipeline` → default or previous in chain |
| Iron law | Medium/large: plan + plan review; trivial/small: assess → implement → PR |
| Merge method | From config; else detect; else `merge` |
| Labels | `pipeline/*` optional via config |
| Plan file path | Discover plans dir; else `docs/plans/` |
| Commit attribution | Project / config / user rules — not hardcoded in pack |
| Run state | Host-neutral checklist; host task APIs optional adapter |
| Parallel implement units | One worktree per issue; subagents do not push |
| Peer agents | Collision STOP; distinct from pipeline subagents |
| `git-ignore-ai` | Pointer when status noisy |

### Review matrix (by scope)

| Scope | Plan review | Code review angles | PR review | Extra project skills |
|-------|-------------|--------------------|-----------|----------------------|
| Trivial / small | Skip | architecture + code-quality | Optional / light | If “always load” |
| Medium / large | Required | All four angles | Required | Mapped + always-load |

---

## Prerequisite: extend `git-worktree`

1. Accept **`base`** (default `origin/<default-branch>`).
2. Accept **`branch`** (required when entry assigns one).
3. Required isolation when caller is `git-issue` / `git-pipeline` / `git-implement`.
4. Keep detect-existing / no-nest / verify pwd+branch / native-then-fallback.
5. Related skills: `git-issue`, `git-pipeline`, `git-implement`.

---

## Hard stops (both entries)

Normative detail in entries + `git-pr` / `git-implement` as linked; do not fork two long copies:

- Never edit the primary checkout for this work.
- Never reuse a peer agent’s worktree/branch.
- Verify `pwd` + branch before every commit/push.
- Collision STOP.
- Partial progress: no `Closes`; issue checklist; deferrals → issues linked in PR.
- Merge-via-API when default branch is checked out elsewhere.

Prefer a short shared bullet list in each entry SKILL (“Hard stops”) that matches; expand merge/partial-progress only in `git-pr`.

---

## Optimize when porting

| Cut / change | How |
|--------------|-----|
| Monolith | Phase skills + thin entries |
| Two fat orchestrators | **Forbidden** — entries only sequence |
| Duplicate worktree / fetch / merge policy | Ownership table |
| Old branch prefix | Drop as pack default; config may override |
| Apache-2.0 source | Pack is Apache-2.0; keep `NOTICE` attribution |

---

## Migration milestones

Commit after each completed M-step (and other significant edits). See CONTRIBUTING “Commits”.

### M0 — Defaults

- [x] Entry split: `git-issue` single / `git-pipeline` stacked batch
- [x] Branch pattern: `<type>/<n>-<slug>`
- [x] Keep `git-issue` as thin entry (rewrite, don’t delete)

### M1 — Skeleton

- [x] Stubs: `git-{pipeline,assess,plan,implement,pr}/`
- [x] Rewrite `git-issue` as number-first thin entry; remove `prompt-template.md`
- [x] `NOTICE` + Apache-2.0 `LICENSE`
- [x] README + CONTRIBUTING skill tables
- [x] Warn about old `issue-pipeline` / `sandbox-git-github` / `ai-gitignore` installs
- [x] Extend `git-worktree` (`base=`, `branch=`, callers) + **remote verification** (origin/upstream/fork)

### M2 — Port (order)

1. [x] `git-assess` + assessment template  
2. [x] `git-plan` + plan-reviewer prompt  
3. [x] `git-implement` + prompts → `git-worktree`  
4. [x] `git-pr` + templates → `git-closes`, `git-sandbox`  
5. [x] `git-issue` thin orchestrator (single)  
6. [x] `git-pipeline` orchestrator + foundation/conventions/triage/completion + merge sequence  
7. [x] Validate all skills + M2 commit  

### M3 — Consistency pass

- [x] Hard stops aligned on both entries; merge/partial detail deferred to `git-pr`
- [x] No pasted phase bodies in either entry
- [x] Symlinks refreshed

### M4 — Retire `issue-pipeline-skill`

- [x] README → `ai-skills-git` (`git-issue` / `git-pipeline`)
- [x] Remove old `issue-pipeline` user install (none present under `~/.claude/skills/`)
- [ ] Archive source when dry-runs pass

### M5 — Prove

- [ ] `git-issue 123` → one PR from default branch
- [ ] `git-pipeline` two dependent issues → stack + sequential merge
- [ ] Sandbox MCP + no subagent push
- [ ] Merge-via-API when primary holds default branch

---

## License

| Component | License |
|-----------|---------|
| Pack (new + adapted) | Apache-2.0 (`LICENSE` + `NOTICE`) |
| Migrated `issue-pipeline-skill` text | Apache-2.0 — attributed in `NOTICE` |

---

## Reference paths

| Path | Role |
|------|------|
| `../issue-pipeline-skill/` | Source tree |
| `skills/git-worktree/` | Extend first (`base=`) |
| `skills/git-sandbox/`, `git-closes/`, `git-ignore-ai/` | Keep; wire |
| `skills/git-issue/` | Rewrite as thin single-issue entry |
