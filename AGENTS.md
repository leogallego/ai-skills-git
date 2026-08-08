# Agent handoff — ai-skills-git

Read this when continuing work on this repository or when Lola installs pack
context (`module/AGENTS.md` is the same brief for AI Context Module installs).

## Goal

Portable **git / forge** skill pack that is:

1. **agentskills.io compliant** — `skills/<name>/SKILL.md`, `name` matches
   directory, valid frontmatter (`license` / `compatibility` / `metadata` ok)
2. **Lola-installable** — skill pack at repo root (`skills/…`); optional richer
   context via `module/AGENTS.md`
3. **Cursor-friendly** — `./scripts/install-cursor.sh` → `~/.cursor/skills/`

Author to the agentskills.io spec; Lola and Cursor distribute.

## Entries

| Skill | Use |
|-------|-----|
| `git-issue` | One issue → one PR from default branch (no stacking) |
| `git-pipeline` | Batch / DAG / stacked PRs; `stack_ci: serial` by default |

Phases: `git-assess` → `git-plan` (medium+) → `git-implement` → `git-pr`.  
Mechanics: `git-worktree` §0 remotes, `git-sandbox`, `git-closes`, `git-ignore-ai`.

## Hard rules (do not regress)

- Never assume `origin` is canonical — map base-remote / push-remote first
- Never edit the primary checkout; isolate via `git-worktree`
- Subagents do not push
- Merge via API when primary holds the default branch
- No “Does not close #N” (GitHub still closes) — `git-closes`
- Stacked CI: rebase next onto new default after each merge; prefer serial CI
- Load **stack-relevant** local skills; `always_load_review_skills` follows config

## Validate / install

```bash
./scripts/validate-skills.sh
./scripts/install-cursor.sh

# Lola skill pack (force repo root — see README)
lola mod add /path/to/ai-skills-git --module-content=/
lola install ai-skills-git --scope user
# optional context append:
# lola install ai-skills-git --scope user --append-context module/AGENTS.md
```

## Docs

- [README.md](README.md) — users / forge scope / install
- [CONTRIBUTING.md](CONTRIBUTING.md) — naming and authoring
- [PIPELINE_PLAN.md](PIPELINE_PLAN.md) — migration status
