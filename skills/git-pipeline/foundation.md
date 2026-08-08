# Foundation context load

Run once at `git-pipeline` start. From `git-issue`, load **lightly** (items
1–2, 5, 9, and anything the issue cites) — full pass optional on medium/large.

Discover only — do not hardcode project paths. Skip missing sources.

## Always-load (if present)

1. Project instructions — `CLAUDE.md`, `AGENTS.md`, `.cursor/rules` (summarize)
2. Global agent instructions — e.g. `~/.claude/CLAUDE.md` (git/PR/attribution bits)
3. Architecture docs — prefer `.git-pipeline.yml` → `architecture.contracts`
   (default discover `docs/architecture/service-contracts.md`), then
   `architecture.adr_dir` / `architecture.strategy` / `architecture.provider`
   when set; else `**/*architecture*/**/*.md` (cap volume; prefer index).
   Missing contracts are OK at foundation time — `git-review` bootstraps later.
4. CI — `.github/workflows/*`, `.gitlab-ci.yml`, `Jenkinsfile`, `.circleci/`
5. Manifests — `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`,
   `build.gradle*`, `pom.xml`, …
6. Build helpers — `Makefile`, `.env.example`, `gradle.properties`
7. Test commands — `scripts/test*`, Makefile/`package.json` test scripts, CI steps
8. Lint config — `ruff`, `eslint`, `biome`, `.editorconfig`, …
9. **Local skill index** — see below (names + descriptions only at this stage)
10. Memory index — `MEMORY.md` if present
11. Git state — current branch, `git log --oneline -10`, open PRs (forge provider)
12. Source layout — top-level `src` / package dirs (sample, don’t dump tree)

Pass the resulting **foundation context** to triage and phase skills/subagents.
Full skill bodies are loaded later via `git-assess` → `skills_needed` (not here).

## Local skill index (discover, don’t preload)

Scan **both** project and user skill roots. Prefer the cross-client
agentskills.io paths, then agent-specific trees:

- Project: `.agents/skills`, `.cursor/skills`, `.claude/skills`, `**/skills`
- User: `~/.agents/skills`, `~/.cursor/skills`, `~/.claude/skills`, host docs

Record `name` + one-line description for each. Matching later uses this
combined index — project and user installs are equal candidates.

**Selection happens in `git-assess`:**

1. **Auto:** skills relevant to this project’s stack and the issue’s paths
   (only if present in the index).
2. **Config:** names in `always_load_review_skills` — load if present, even
   when off-stack (manual entry wins).

| Stack signals | Auto-prefer skills about… (if installed) |
|---------------|------------------------------------------|
| `pyproject.toml`, `*.py` | Python style, typing, tests, packaging |
| Android/Gradle/Kotlin | Kotlin, Android UI, app architecture |
| `package.json` / TS | Frontend/TS conventions for that repo |

Never auto-load “every Python skill” on a Kotlin repo or vice versa. Unrelated
installs stay in the index unused unless named in config.
