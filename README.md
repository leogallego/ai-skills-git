# ai-skills-git

Portable **git / GitHub agent skills** for remotes-aware worktrees, single-issue
and multi-issue pipelines, sandbox tool routing, and AI-aware ignore hygiene.

- **Format:** [agentskills.io](https://agentskills.io/specification) (`skills/<name>/SKILL.md`)
- **Install:** [Lola](https://github.com/LobsterTrap/lola), Cursor skill symlinks, or Claude Code plugin
- **Peers:** [`ai-skills-python`](../ai-skills-python), [Superpowers](https://github.com/obra/superpowers) (optional)

This pack is **standalone**. If Superpowers is installed, prefer its worktree
skill when already loaded (after **remote verification**); otherwise use
**`git-worktree`**.

Development: [CONTRIBUTING.md](CONTRIBUTING.md).  
Pipeline migration: [PIPELINE_PLAN.md](PIPELINE_PLAN.md).  
Architecture review skill: [GIT_REVIEW_SPEC.md](GIT_REVIEW_SPEC.md).

---

## Status

M5 prove complete on this repo. Apache-2.0. **Tracker/PR API is GitHub-first**
(see [Forge scope](#forge-scope)).

## Forge scope

Plain **git** layers work against any remote (GitHub, GitLab, Gitea, Forgejo).
Issue/PR/MR APIs use **`forge.provider`** (default `github`):

| Provider | Skill doc | Tools |
|----------|-----------|--------|
| `github` (default) | `git-sandbox` | GitHub MCP / `gh` |
| `gitlab` | `forge-gitlab.md` | `glab` / GitLab API |
| `gitea` / `forgejo` | `forge-gitea.md` | `tea` / REST `/api/v1` |

| Layer | Portable? | Skills |
|-------|-----------|--------|
| Remotes, fetch, worktree, commit, push | Yes | `git-worktree`, most of `git-implement` |
| Sandbox transport + SSH signing | Yes (allowlist the forge host) | `git-sandbox` |
| Issues, PRs/MRs, merge API, close verify | Via active forge provider | entries + `git-pr` / `git-closes` |

Configure `forge.provider` in `.git-pipeline.yml` — see conventions and
`git-sandbox`.

## Skills

All names follow `git-<concern>` (see CONTRIBUTING).

| Skill | Domain | Role | Forge |
|-------|--------|------|-------|
| `git-worktree` | Mechanics | Verify remotes (origin/upstream/fork), then isolate with `base=` / `branch=` | Portable |
| `git-issue` | Entry (single) | One issue → assess → plan? → implement → PR (no stacking) | Active forge |
| `git-pipeline` | Entry (batch) | Multi-issue triage, stacks, sequential merge | Active forge |
| `git-assess` | Phase | Issue vs codebase assessment | Active forge |
| `git-plan` | Phase | Plan + plan review | Portable* |
| `git-implement` | Phase | Worktree + implement + review + fix | Portable* |
| `git-review` | Phase | Architecture contract review (+ scaffold offer) | Portable* |
| `git-pr` | Phase | One PR/MR + Closes + merge mechanics | Active forge |
| `git-sandbox` | Environment | git CLI vs forge API; SSH commit signing | Mixed |
| `git-ignore-ai` | Hygiene | AI-aware `.gitignore` | Portable |
| `git-closes` | Hygiene | Verify issue # before `Closes` / `Fixes` | Active forge |

\*Plan/implement git mechanics are portable; tracker ops use the active forge.

| Need | Use |
|------|-----|
| Which remote is canonical / fork? | **`git-worktree` §0** (before any fetch/push) |
| One issue | **`git-issue 123`** |
| Many issues / stacks | **`git-pipeline #1 #2`** (`stack_ci: serial` avoids CI rebuild cascades) |
| Sandbox / GPG broken | **`git-sandbox`** |
| Wrong `Closes #N` / “Does not close #N” false positive | **`git-closes`** |
| AI junk in `git status` | **`git-ignore-ai`** |
| Which language/domain skills to load? | **`git-assess`** maps locally installed skills to the project stack (Python vs Kotlin/Android vs …) — never force unrelated packs |
| Architecture / layer contracts on a branch or PR? | **`git-review`** (needs `docs/architecture/service-contracts.md` or offers to scaffold) |

## Layout

```text
ai-skills-git/
├── README.md
├── AGENTS.md                 # agent / Lola handoff (pack root)
├── CONTRIBUTING.md
├── PIPELINE_PLAN.md
├── LICENSE
├── NOTICE
├── .claude-plugin/plugin.json
├── module/
│   └── AGENTS.md             # optional Lola AI Context Module entry
├── docs/architecture/service-contracts.md
├── .git-pipeline.yml
├── scripts/
│   ├── install-agents.sh     # ~/.agents/skills (+ cursor/claude mirrors)
│   ├── install-cursor.sh     # wrapper → install-agents.sh
│   └── validate-skills.sh
└── skills/
    ├── git-worktree/
    ├── git-issue/
    ├── git-pipeline/
    ├── git-assess/
    ├── git-plan/
    ├── git-implement/
    ├── git-review/
    ├── git-pr/
    ├── git-sandbox/
    ├── git-ignore-ai/
    └── git-closes/
```

## Install

Prefer the **cross-client** path ([agentskills.io](https://agentskills.io)
`~/.agents/skills/`), then mirror into agent-specific dirs when present.

```bash
# Recommended — ~/.agents/skills + mirrors to ~/.cursor/skills and
# ~/.claude/skills when those agents exist on the machine
./scripts/install-agents.sh

# Alternative: vercel-labs skills CLI (also targets .agents/skills)
# npx skills add /path/to/ai-skills-git -g --all

# Lola skill pack — force repo root so skills/ is discovered
# (Lola prefers module/ when present; our skills stay at pack root)
# lola mod add /path/to/ai-skills-git --module-content=/
# lola install ai-skills-git --scope user
# Optional: --append-context module/AGENTS.md

# Claude Code plugin (discovers pack-root skills/)
# claude plugin add /path/to/ai-skills-git
```

`scripts/install-cursor.sh` remains as a **compatibility wrapper** that calls
`install-agents.sh` (do not use it as the primary path).

After adding a **new** skill directory, re-run `install-agents.sh` once so new
symlinks appear (existing links keep working for updates).

**Avoid duplicates:** remove or disable old installs that conflict:

- `~/.claude/skills/issue-pipeline` (use `git-pipeline` / `git-issue`)
- `~/.claude/skills/sandbox-git-github` (use `git-sandbox`)
- `~/.claude/skills/ai-gitignore` (use `git-ignore-ai`)

Then start a new agent session so skills reload.

## Validate

```bash
./scripts/validate-skills.sh
# equivalent:
# for d in skills/*/; do uvx --from skills-ref agentskills validate "$d"; done
```

## License

Apache License 2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE).
