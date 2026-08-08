# Contributing — ai-skills-git

Development guide for this pack: naming, authoring, candidate evaluation, and next steps.

## Naming

**Rule:** every skill is `git-<concern>`.

| Rule | Detail |
|------|--------|
| Prefix | Always `git-` |
| Concern | Short kebab phrase for the job (1–2 tokens after `git-`) |
| Match | Directory name == `name:` frontmatter |
| Case | lowercase ASCII, hyphens only; max 64 chars |
| Collisions | Never reuse a Superpowers skill name (`using-git-worktrees` stays theirs; ours is `git-worktree`) |

| Skill | Domain | Job |
|-------|--------|-----|
| `git-worktree` | Mechanics | Verify remotes; create worktree with `base=` / `branch=` |
| `git-issue` | Entry | Single issue number → phase sequence (no stack) |
| `git-pipeline` | Entry | Batch triage, stacks, sequential merge |
| `git-assess` | Phase | Issue vs codebase assessment |
| `git-plan` | Phase | Plan + plan review |
| `git-implement` | Phase | Isolate + implement + review + fix |
| `git-pr` | Phase | One PR, Closes, single-PR merge |
| `git-sandbox` | Environment | Tool routing + SSH commit signing |
| `git-ignore-ai` | Hygiene | AI-aware `.gitignore` |
| `git-closes` | Hygiene | Confirm issue number before `Closes` / `Fixes` |

Do not invent unprefixed or mixed-family names (`ai-gitignore`, `parallel-issue-work`, `sandbox-git-github`).

`metadata.collection` is optional grouping (`workflow`, `sandbox`, `gitignore`, `hygiene`). It does not replace the `git-` prefix.

Descriptions must state **what** + **when** (third person, ≤1024 chars).

## Authoring

Format: [agentskills.io](https://agentskills.io/specification). Peer layout: [`ai-skills-python`](../ai-skills-python).

```yaml
---
name: git-sandbox
description: >-
  Routes git and GitHub ops under restricted sandboxes (no AF_UNIX / keyring).
  Use when gh auth fails, git push stalls in sandbox, or choosing git CLI vs
  GitHub MCP.
license: Apache-2.0
compatibility: >-
  Agentskills.io clients. Optional Lola install. Standalone worktrees via
  git-worktree; Superpowers optional peer.
metadata:
  author: Leonardo Gallego
  version: "1.0.0"
  collection: sandbox
  claude-argument-hint: "…"          # optional; keep under metadata
  claude-user-invocable: "true"
  claude-disable-model-invocation: "true"
---
```

Keep Claude-only keys under `metadata.claude-*` (not top-level).

**Body:** Overview → When to use / not → Instructions → Platform adapters (if needed) → Failure modes → Related skills. Stay under ~500 lines; put prompt templates in `prompt-template.md` beside `SKILL.md`.

**Principles:**

1. **Standalone first** — pack works without Superpowers. `git-worktree` owns mechanics here.
2. **Optional Superpowers peer** — if `using-git-worktrees` is already loaded, `git-worktree` may defer to it; never require it.
3. One concern per skill — one-line pointers only for overlap (`git-issue` calls `git-worktree`).
4. Generic defaults — discover project review skills; don’t hardcode repo paths.
5. Hard stops in workflow skills (wrong branch, issue fixed, agent collision, empty prompt).

**Dedup check before adding text:** Sibling owns it? → pointer. Superpowers loaded and equivalent? → optional defer. Project quirk? → stay out of the pack.

**`git-worktree` procedure order:**

1. **Verify remotes** — map base-remote vs push-remote (fork/upstream); never assume `origin`
2. Detect existing isolation (already in a linked worktree → don’t nest)
3. Prefer native host tools (Cursor `move_agent_to_root` / worktree helpers, Claude `EnterWorktree`, …)
4. Else `git worktree add` fallback (`base=` ref; path ignored)
5. Verify `pwd` and `git branch --show-current` before any edits
6. If Superpowers `using-git-worktrees` is already in context, defer isolation mechanics after remotes

**Validate:**

```bash
uvx --from skills-ref agentskills validate skills/<name>/
grep -q "^name: $(basename skills/<name>)$" skills/<name>/SKILL.md
```

## Evaluation (sources → v1)

| Source | Verdict |
|--------|---------|
| `~/.claude/skills/ai-gitignore` | → **`git-ignore-ai`** (one job; light path genericizing) |
| `~/.claude/skills/sandbox-git-github` | Kitchen sink → split (table below) |
| Isolation preamble (paste) | → hard stops on entries; worktree → **`git-worktree`** |
| `issue-pipeline-skill` | → **`git-pipeline`** + phase skills (see PIPELINE_PLAN) |
| Superpowers `using-git-worktrees` | Optional peer after remotes verified |

### Ownership (normative home)

| Concern | Owner |
|---------|-------|
| Remote map (origin / upstream / fork) | **`git-worktree` §0** (entries must run before fetch/push) |
| Create / enter worktree (`base=`, `branch=`) | **`git-worktree`** |
| Single-issue entry | `git-issue` |
| Batch / stack / merge sequence | `git-pipeline` |
| Assess / plan / implement / one PR | `git-assess` / `git-plan` / `git-implement` / `git-pr` |
| Sandbox tool route + SSH signing | `git-sandbox` |
| AI `.gitignore` | `git-ignore-ai` |
| `Closes #` verify | `git-closes` |

## Forge scope (GitHub-first)

**GitHub-first** for tracker and pull-request APIs. Do not document or implement
entry skills as if Gitea/GitLab worked end-to-end until a forge provider lands
(Related to #3, then #1 / #4).

| Portable (plain git) | GitHub-bound today |
|----------------------|--------------------|
| `git-worktree`, `git-ignore-ai`, commit/push via `git-sandbox` | `git-issue`, `git-pipeline`, `git-assess`, `git-pr`, `git-closes` |

When authoring: keep remote/worktree text forge-agnostic; put `gh` / GitHub MCP
behind an explicit provider note (default: GitHub). Unknown forge → STOP and
say what still works (git-only).

## Commits

Commit after every significant change. At minimum, **one commit per completed PIPELINE_PLAN milestone (M0, M1, …)** and after substantive skill/doc edits (e.g. sandbox signing guidance). Prefer SSH commit signing (`git-sandbox`); never skip signing.

## Progress

- [x] Five `git-*` names + domains
- [x] `git init -b main`; Apache-2.0 `LICENSE` + `NOTICE`, `.gitignore`, `.claude-plugin/plugin.json`, `scripts/install-cursor.sh`
- [x] Implement `skills/git-{worktree,issue,sandbox,ignore-ai,closes}/`
- [x] Validate with `skills-ref`; Cursor + Claude skill symlinks installed
- [x] Initial commit on `main`
- [x] M1 skeleton (stubs, `git-issue` rewrite, remotes in `git-worktree`)
- [x] M2 port phase content from `issue-pipeline-skill`
- [x] M3 consistency (entry hard stops; thin orchestrators)
- [x] M4 source README superseded banner (`issue-pipeline-skill`)
- [ ] Remove old `~/.claude/skills/{ai-gitignore,sandbox-git-github,issue-pipeline}` when ready
- [x] M5 prove on this repo (`git-issue` / stacked `git-pipeline`)
- [x] GitHub remote (`origin` → `leogallego/ai-skills-git`)

**Defaults chosen:** `git-ignore-ai` writes `.ai/git-ignore-ai-baseline.json` (reads legacy `.claude/ai-gitignore-baseline.json`). Workflow skills are auto-discoverable (no `claude-disable-model-invocation`). Pack license: Apache-2.0.
