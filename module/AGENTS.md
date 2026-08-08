# ai-skills-git — Lola module context

This repository is primarily an agentskills.io **skill pack** (`skills/` at the
repo root). This file is the optional **AI Context Module** entry for Lola
(`--append-context module/AGENTS.md`).

For the full agent handoff (validate, install, hard rules), read the pack-root
[AGENTS.md](../AGENTS.md) after install, or the copy under the module store.

## Quick map

| Need | Skill |
|------|--------|
| Remotes / worktree | `git-worktree` |
| One issue | `git-issue` |
| Many issues / stacks | `git-pipeline` |
| Sandbox / signing | `git-sandbox` |
| Closes wording | `git-closes` |
| AI `.gitignore` | `git-ignore-ai` |

**GitHub-first** for issue/PR APIs; plain git (fetch/worktree/push) is
forge-portable. See pack README forge scope.

## Install note

Register the pack with content at the **repository root** so `skills/` is
discovered (a bare `module/` preference would miss root `skills/`):

```bash
lola mod add https://github.com/leogallego/ai-skills-git.git --module-content=/
lola install ai-skills-git --scope user --append-context module/AGENTS.md
```
