# Foundation context load

Run once at `git-pipeline` start. From `git-issue`, load **lightly** (items
1–2, 5, 9, and anything the issue cites) — full pass optional on medium/large.

Discover only — do not hardcode project paths. Skip missing sources.

## Always-load (if present)

1. Project instructions — `CLAUDE.md`, `AGENTS.md`, `.cursor/rules` (summarize)
2. Global agent instructions — e.g. `~/.claude/CLAUDE.md` (git/PR/attribution bits)
3. Architecture docs — `**/*architecture*/**/*.md` (cap volume; prefer index)
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

Scan installed skill roots (project + `~/.cursor/skills` + `~/.claude/skills` +
host docs). Record `name` + one-line description for each.

**Selection happens in `git-assess`:** pick only skills relevant to this
project’s stack and the issue’s paths. Examples of *relevance* (illustrative —
only if that skill is actually installed):

| Stack signals | Prefer skills about… |
|---------------|----------------------|
| `pyproject.toml`, `*.py` | Python style, typing, tests, packaging |
| Android/Gradle/Kotlin | Kotlin, Android UI, app architecture |
| `package.json` / TS | Frontend/TS conventions for that repo |

Never load “every Python skill” on a Kotlin repo or vice versa. Unrelated local
installs stay in the index unused.
