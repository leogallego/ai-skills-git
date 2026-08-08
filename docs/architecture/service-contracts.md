# Architecture Service Contracts — ai-skills-git

Enforceable rules for this skill pack. Reviewed by `git-review`.
**Hard rules** must be fixed before merge. **Soft guidelines** are advisory.

This is a documentation / skill-pack repo (no application runtime). “Layers”
are pack layout concerns, not service tiers.

## Layer map

| Path / pattern | Layer |
|----------------|-------|
| `skills/*/SKILL.md` | **Skill** — one `git-<concern>` unit |
| `skills/*/*.md` (prompts, templates beside a skill) | **Skill** — owned by that skill |
| `skills/git-pipeline/conventions.md`, `foundation.md`, … | **Shared workflow docs** — loaded by phase/entry skills |
| `scripts/*` | **Tooling** — validate / install only |
| `module/AGENTS.md`, pack-root `AGENTS.md` | **Pack context** — Lola / agent handoff |
| `README.md`, `CONTRIBUTING.md`, `PIPELINE_PLAN.md`, `GIT_REVIEW_SPEC.md` | **Pack docs** |
| `.claude-plugin/plugin.json` | **Distribution metadata** |
| `docs/architecture/*` | **Architecture** — contracts / ADRs |
| `.git-pipeline.yml` | **Conventions config** |

## Dependency rules

```text
Entry skills (git-issue, git-pipeline)
  → phase skills (assess / plan / implement / review / pr)
  → mechanics (git-worktree, git-sandbox, git-closes, git-ignore-ai)
  → shared docs (conventions, foundation, prompts)

Skill units MUST NOT depend on product-repo paths or stack-specific rules.
Tooling and pack docs MUST NOT embed normative workflow that belongs in a skill.
```

- Higher workflow orchestration may call lower mechanics; mechanics must not
  own entry/phase procedures.
- Shared docs are read by skills; they are not executable skills themselves.
- Do not invent cross-skill imports of large duplicated procedure text —
  **pointer** to the owning skill (see CONTRIBUTING dedup rule).

## Hard rules

- [x] **Naming:** every skill directory and frontmatter `name:` is `git-<concern>`
  (lowercase, hyphens). Directory name matches `name:`.
- [x] **One concern per skill.** Overlap is one-line pointers only.
- [x] **No product-repo rules in skills.** Layer maps, DI, TypedDicts, Koin, etc.
  belong in *consuming* repos’ `service-contracts.md`, not this pack.
- [x] **Remotes:** never assume `origin` is canonical — `git-worktree` §0 owns
  base-remote / push-remote mapping before fetch/push.
- [x] **Isolation:** feature work and pipeline implement run in a linked
  worktree (`git-worktree`); do not edit the primary checkout.
- [x] **Subagents do not push.**
- [x] **Closes hygiene:** no “Does not close #N” (and similar) — `git-closes`.
- [x] **Stack-filtered skills:** `git-assess` loads stack-relevant skills;
  only `always_load_review_skills` bypasses that filter.
- [x] **Contracts discovery:** `git-review` reads
  `architecture.contracts` / `docs/architecture/service-contracts.md`;
  missing/empty → bootstrap offer, never invent a Clean review.
- [x] **agentskills.io compliance:** each skill has valid frontmatter;
  `./scripts/validate-skills.sh` must pass before merge when skills change.

## Soft guidelines

- [x] Keep each `SKILL.md` under ~500 lines; put long prompts in sibling `.md`
  files.
- [x] Prefer `~/.agents/skills/` (cross-client) for user installs; agent-specific
  dirs (`~/.cursor/skills`, `~/.claude/skills`) are mirrors when needed.
- [ ] File size: prefer focused skill files; split when a prompt template
  dominates the skill body.
- [ ] When adding a phase skill, update README / AGENTS / CONTRIBUTING ownership
  tables in the same change.
- [ ] Spec/design docs (`*_SPEC.md`, `PIPELINE_PLAN.md`) stay at pack root or
  under `docs/`; skills must not require them at runtime.

## Known exceptions

| ID | Summary | Status |
|----|---------|--------|
| E-L1 | `git-pipeline` ships multiple helper `.md` files (conventions, foundation, prompts) — intentional shared workflow docs, not separate skills | Accepted |
| E-R1 | `git-review` report uses Error/Warning/Info labels; implement/pr Finding severity uses `critical`/`warning`/`info` — mapped at the boundary | Accepted |

## Companion skills (optional)

| When files match | Load skill (if installed) |
|------------------|---------------------------|
| `skills/**`, pack docs | `git-review` |
| Install / symlink scripts | — (validate via `scripts/validate-skills.sh`) |

## Notes

- Source of truth for pack architecture is **this file**. Do not re-create a
  fat project `pr-architecture-review` skill here.
- Configure discovery in `.git-pipeline.yml` → `architecture.contracts`.
