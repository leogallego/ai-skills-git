# Foundation context load

Run once at `git-pipeline` start (and lightly from `git-issue` when useful).
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
9. Skill index — `**/skills/*/SKILL.md` (first ~15 lines each: name + description)
10. Memory index — `MEMORY.md` if present
11. Git state — current branch, `git log --oneline -10`, open PRs (MCP/`gh`)
12. Source layout — top-level `src` / package dirs (sample, don’t dump tree)

Pass the resulting **foundation context** to triage and phase skills/subagents.
