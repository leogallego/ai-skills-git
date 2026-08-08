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

---

## Status

M5 prove complete on this repo. Apache-2.0. **Tracker/PR API is GitHub-first**
(see [Forge scope](#forge-scope)).

## Forge scope

Plain **git** layers work against any remote (GitHub, GitLab, Gitea, Forgejo).
Issue fetch, PR/MR open, review, merge-via-API, and `Closes` verify currently
require **GitHub** (`gh` and/or GitHub MCP). Local Gitea / `gitlab.com` remotes
are fine for worktree + push; `git-issue` / `git-pipeline` will fail or STOP
when they need a non-GitHub tracker API.

| Layer | Off-GitHub today? | Skills |
|-------|-------------------|--------|
| Remotes, fetch, worktree, commit, push | Yes | `git-worktree`, most of `git-implement` |
| Sandbox transport + SSH signing | Mostly (examples still say `github.com`) | `git-sandbox` |
| Issues, PRs, labels, merge API, close verify | No — GitHub only | `git-issue`, `git-pipeline`, `git-assess`, `git-pr`, `git-closes` |

Configure `forge.provider` in `.git-pipeline.yml` (default `github`) — see
`git-pipeline` conventions and `git-sandbox`. Concrete adapters: Related to #1
(GitLab), Related to #4 (Gitea/Forgejo).

## Skills

All names follow `git-<concern>` (see CONTRIBUTING).

| Skill | Domain | Role | Forge |
|-------|--------|------|-------|
| `git-worktree` | Mechanics | Verify remotes (origin/upstream/fork), then isolate with `base=` / `branch=` | Portable |
| `git-issue` | Entry (single) | One issue → assess → plan? → implement → PR (no stacking) | GitHub API |
| `git-pipeline` | Entry (batch) | Multi-issue triage, stacks, sequential merge | GitHub API |
| `git-assess` | Phase | Issue vs codebase assessment | GitHub API |
| `git-plan` | Phase | Plan + plan review | Portable* |
| `git-implement` | Phase | Worktree + implement + review + fix | Portable* |
| `git-pr` | Phase | One PR + Closes + merge mechanics | GitHub API |
| `git-sandbox` | Environment | git CLI vs GitHub MCP; SSH commit signing | Mixed |
| `git-ignore-ai` | Hygiene | AI-aware `.gitignore` | Portable |
| `git-closes` | Hygiene | Verify issue # before `Closes` / `Fixes` | GitHub API |

\*Plan/implement git mechanics are portable; they inherit GitHub when the caller
fetched the issue via GitHub.

| Need | Use |
|------|-----|
| Which remote is canonical / fork? | **`git-worktree` §0** (before any fetch/push) |
| One issue | **`git-issue 123`** |
| Many issues / stacks | **`git-pipeline #1 #2`** (`stack_ci: serial` avoids CI rebuild cascades) |
| Sandbox / GPG broken | **`git-sandbox`** |
| Wrong `Closes #N` / “Does not close #N” false positive | **`git-closes`** |
| AI junk in `git status` | **`git-ignore-ai`** |
| Which language/domain skills to load? | **`git-assess`** maps locally installed skills to the project stack (Python vs Kotlin/Android vs …) — never force unrelated packs |

## Layout

```text
ai-skills-git/
├── README.md
├── CONTRIBUTING.md
├── PIPELINE_PLAN.md
├── LICENSE
├── NOTICE
├── .claude-plugin/plugin.json
├── scripts/install-cursor.sh
└── skills/
    ├── git-worktree/
    ├── git-issue/
    ├── git-pipeline/
    ├── git-assess/
    ├── git-plan/
    ├── git-implement/
    ├── git-pr/
    ├── git-sandbox/
    ├── git-ignore-ai/
    └── git-closes/
```

## Install

```bash
# Lola
lola mod add /path/to/ai-skills-git && lola install ai-skills-git --scope user

# Cursor native skills
./scripts/install-cursor.sh

# Claude Code plugin
claude plugin add /path/to/ai-skills-git
```

**Avoid duplicates:** remove or disable old installs that conflict:

- `~/.claude/skills/issue-pipeline` (use `git-pipeline` / `git-issue`)
- `~/.claude/skills/sandbox-git-github` (use `git-sandbox`)
- `~/.claude/skills/ai-gitignore` (use `git-ignore-ai`)

Then start a new agent chat so skills reload.

## License

Apache License 2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE).
