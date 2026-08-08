# ai-skills-git

Portable **git / GitHub agent skills** for worktrees, multi-agent issue work, sandbox tool routing, and AI-aware ignore hygiene.

- **Format:** [agentskills.io](https://agentskills.io/specification) (`skills/<name>/SKILL.md`)
- **Install:** [Lola](https://github.com/LobsterTrap/lola), Cursor skill symlinks, or Claude Code plugin
- **Peers:** [`ai-skills-python`](../ai-skills-python), [Superpowers](https://github.com/obra/superpowers) (optional)

This pack is **standalone**. If Superpowers is installed, prefer its worktree skill when already loaded; otherwise use **`git-worktree`**.

Development (naming, authoring): [CONTRIBUTING.md](CONTRIBUTING.md).  
Pipeline migration from `issue-pipeline-skill`: [PIPELINE_PLAN.md](PIPELINE_PLAN.md).

---

## Status

v1 skills implemented under `skills/`. Install helpers ready; publish/remote optional.

## Skills

All names follow `git-<concern>` (see CONTRIBUTING).

| Skill | Domain | Role |
|-------|--------|------|
| `git-worktree` | Mechanics | Detect/create isolated worktree + branch; move agent root; verify `pwd` / branch |
| `git-issue` | Process | Multi-agent issue workflow: preflight, scope, review gates, one PR, safe merge, deferrals |
| `git-sandbox` | Environment | Choose git CLI vs GitHub MCP when the sandbox breaks `gh` / keyring / sockets |
| `git-ignore-ai` | Hygiene | Baseline + update loop for AI-aware `.gitignore` |
| `git-closes` | Hygiene | Confirm the issue number before `Closes` / `Fixes` |

| Need | Use |
|------|-----|
| Create / enter a worktree | **`git-worktree`** (or Superpowers if already loaded) |
| Parallel agents on one repo | **`git-issue`** (calls `git-worktree` for isolation) |
| Sandbox git/GitHub tooling | **`git-sandbox`** |
| Wrong `Closes #N` | **`git-closes`** |
| AI junk in `git status` | **`git-ignore-ai`** |

Migrates from: `ai-gitignore`, `sandbox-git-github`, and the isolation preamble paste.

## Layout (target)

```text
ai-skills-git/
├── README.md
├── CONTRIBUTING.md
├── LICENSE
├── .claude-plugin/plugin.json
├── scripts/install-cursor.sh
└── skills/
    ├── git-worktree/SKILL.md
    ├── git-issue/
    │   ├── SKILL.md
    │   └── prompt-template.md
    ├── git-sandbox/SKILL.md
    ├── git-ignore-ai/SKILL.md
    └── git-closes/SKILL.md
```

## Install (planned)

```bash
# Lola
lola mod add /path/to/ai-skills-git && lola install ai-skills-git --scope user

# Cursor native skills
./scripts/install-cursor.sh

# Claude Code plugin
claude plugin add /path/to/ai-skills-git
```

Then remove old `~/.claude/skills/{ai-gitignore,sandbox-git-github}` so nothing double-loads.

## License

Apache License 2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE).
