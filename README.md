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

M2 phase port complete (assess/plan/implement/pr/pipeline). Apache-2.0.

## Skills

All names follow `git-<concern>` (see CONTRIBUTING).

| Skill | Domain | Role |
|-------|--------|------|
| `git-worktree` | Mechanics | Verify remotes (origin/upstream/fork), then isolate with `base=` / `branch=` |
| `git-issue` | Entry (single) | One issue → assess → plan? → implement → PR (no stacking) |
| `git-pipeline` | Entry (batch) | Multi-issue triage, stacks, sequential merge |
| `git-assess` | Phase | Issue vs codebase assessment |
| `git-plan` | Phase | Plan + plan review |
| `git-implement` | Phase | Worktree + implement + review + fix |
| `git-pr` | Phase | One PR + Closes + merge mechanics |
| `git-sandbox` | Environment | git CLI vs GitHub MCP; SSH commit signing |
| `git-ignore-ai` | Hygiene | AI-aware `.gitignore` |
| `git-closes` | Hygiene | Verify issue # before `Closes` / `Fixes` |

| Need | Use |
|------|-----|
| Which remote is canonical / fork? | **`git-worktree` §0** (before any fetch/push) |
| One issue | **`git-issue 123`** |
| Many issues / stacks | **`git-pipeline #1 #2`** |
| Sandbox / GPG broken | **`git-sandbox`** |
| Wrong `Closes #N` / “Does not close #N” false positive | **`git-closes`** |
| AI junk in `git status` | **`git-ignore-ai`** |

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
