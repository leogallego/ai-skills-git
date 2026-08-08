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
| `git-worktree` | Mechanics | Detect/create worktree + branch; move agent root; verify location |
| `git-issue` | Process | Multi-agent issue workflow (preflight → isolation → PR → merge) |
| `git-sandbox` | Environment | Tool routing under restricted sandboxes (git CLI vs GitHub MCP) |
| `git-ignore-ai` | Hygiene | Baseline + update loop for AI-aware `.gitignore` |
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

1. Detect existing isolation (already in a linked worktree → don’t nest)
2. Prefer native host tools (Cursor `move_agent_to_root` / worktree helpers, Claude `EnterWorktree`, …)
3. Else `git worktree add` fallback (project convention for path; ensure ignored)
4. Verify `pwd` and `git branch --show-current` before any edits
5. If Superpowers `using-git-worktrees` is already in context, follow that instead of re-deriving steps

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
| Isolation preamble (paste) | → **`git-issue`** (+ `prompt-template.md`); worktree steps → **`git-worktree`** |
| Superpowers `using-git-worktrees` | Optional peer — pack ships **`git-worktree`** so install is not required |

### Split of `sandbox-git-github`

| Section | Home |
|---------|------|
| Tool selection, `gh`/AF_UNIX, SSH, signing, push stalls | **`git-sandbox`** |
| Always use worktrees (full procedure) | **`git-worktree`** |
| Never work on main / multi-agent isolation | **`git-issue`** |
| Verify issue # before `Closes` | **`git-closes`** |
| Worktree + Python `pythonpath` | Short note inside **`git-worktree`** or **`git-issue`** (optional later extract) |
| Post-merge local sync | Fold into **`git-issue`** merge steps |

### Ownership (normative home)

| Concern | Owner |
|---------|-------|
| Create / enter worktree | **`git-worktree`** (defer to Superpowers only if already loaded) |
| Don’t edit primary / issue preflight / collision STOP / merge-via-API | `git-issue` |
| Sandbox tool route | `git-sandbox` |
| AI `.gitignore` | `git-ignore-ai` |
| `Closes #` verify | `git-closes` |

Out of v1 as standalone skills: post-merge sync, Python worktree env (too thin).

## Commits

Commit after every significant change. At minimum, **one commit per completed PIPELINE_PLAN milestone (M0, M1, …)** and after substantive skill/doc edits (e.g. sandbox signing guidance). Prefer SSH commit signing (`git-sandbox`); never skip signing.

## Progress

- [x] Five `git-*` names + domains
- [x] `git init -b main`; Apache-2.0 `LICENSE` + `NOTICE`, `.gitignore`, `.claude-plugin/plugin.json`, `scripts/install-cursor.sh`
- [x] Implement `skills/git-{worktree,issue,sandbox,ignore-ai,closes}/`
- [x] Validate with `skills-ref`; Cursor + Claude skill symlinks installed
- [x] Initial commit on `main`
- [ ] Retire old `~/.claude/skills/{ai-gitignore,sandbox-git-github}` (still present — remove when ready)
- [ ] GitHub remote when asked

**Defaults chosen:** `git-ignore-ai` writes `.ai/git-ignore-ai-baseline.json` (reads legacy `.claude/ai-gitignore-baseline.json`). Workflow skills are auto-discoverable (no `claude-disable-model-invocation`). Pack license: Apache-2.0.
