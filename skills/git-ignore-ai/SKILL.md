---
name: git-ignore-ai
description: >-
  Creates and maintains a .gitignore that protects original files and tracks
  AI-generated content. On first run generates a baseline; on later runs detects
  new untracked files and asks whether each should be ignored. Use when setting
  up AI hygiene for a repo or when git status is noisy with agent output.
license: Apache-2.0
compatibility: >-
  Agentskills.io clients (Cursor, Claude Code, …). Optional Lola install.
metadata:
  author: Leonardo Gallego
  version: "1.0.0"
  collection: gitignore
  claude-argument-hint: "[path to repo root, defaults to current directory]"
  claude-user-invocable: "true"
---

# git-ignore-ai

Manage a `.gitignore` that protects original files and progressively captures
AI-generated content.

**Repo root:** user argument if provided, else current working directory. All
paths are relative to that root.

**Formerly:** `ai-gitignore`.

## Baseline file location

Prefer (in order):

1. `.ai/git-ignore-ai-baseline.json`
2. Legacy: `.claude/ai-gitignore-baseline.json` (still valid if present)

If neither exists → **BASELINE MODE**. If either exists → **UPDATE MODE**
(load the one found; prefer `.ai/` when writing a new baseline).

Ignore the baseline file itself from git (list it under the AI section of
`.gitignore`).

---

## BASELINE MODE

### 1. Detect project type

Signals (a repo can match several):

| Signal | Type |
|--------|------|
| `package.json` | Node.js |
| `requirements.txt`, `pyproject.toml`, `setup.py` | Python |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `pom.xml`, `build.gradle` | Java |
| `roles/`, `playbooks/`, playbook YAML | Ansible |
| `Makefile` | Make-based |
| `*.tf` | Terraform |
| `Dockerfile` | Docker |
| `Gemfile` | Ruby |
| `.claude/` / `.cursor/` | Agent-assisted project |

### 2. Snapshot state

```bash
git -C <repo_root> ls-files
git -C <repo_root> status --porcelain
git -C <repo_root> ls-files --others --exclude-standard
```

Collect `tracked_files` and `already_untracked`.

### 3. Generate baseline `.gitignore`

If `.gitignore` exists, read it first. **Append only** — never remove rules.

Add commented sections as needed:

**Agent / AI (always consider):**

```gitignore
# Agent / AI
.claude/settings.local.json
.claude/*.local.md
.claude/ai-gitignore-baseline.json
.ai/git-ignore-ai-baseline.json
*-generated.*
ai-output/
generated/
```

**Language sections** — only for detected types (Node `node_modules/`, Python
`__pycache__/` / `.venv/`, Go, Terraform, Ansible `*.retry`, etc.).

**General:** `.DS_Store`, editor junk, `*.bak`, `*.orig`.

### 4. Write baseline JSON

Write `.ai/git-ignore-ai-baseline.json` (create `.ai/`):

```json
{
  "created_at": "<ISO timestamp>",
  "repo_root": "<absolute path>",
  "project_types": ["<detected types>"],
  "tracked_files_count": 0,
  "baseline_untracked": ["<already untracked at baseline>"],
  "user_ignored": []
}
```

`baseline_untracked` must not be treated as AI-generated later.

### 5. Report

Tell the user: detected types, sections added, that later runs review new
untracked files.

---

## UPDATE MODE

### 1. Load baseline

Read `.ai/git-ignore-ai-baseline.json` or legacy `.claude/ai-gitignore-baseline.json`.

### 2. Candidates

```bash
git -C <repo_root> ls-files --others --exclude-standard
```

Subtract `baseline_untracked` and `user_ignored`. Remainder = candidates.

### 3. Group

Same directory → directory pattern; same extension → glob; else individual files.

### 4. Ask the user

For each candidate/group:

> New file(s) that may be AI-generated: `<path or group>`
> Add to .gitignore? [yes / no / always ignore this pattern]

Use the host’s ask-user tool when available.

### 5. Apply

- **Yes:** append pattern to `.gitignore`; record paths in `user_ignored`.
- **No:** record in `user_ignored` with `keep: true` (do not ask again).

Never remove existing `.gitignore` entries. Never ignore a file that is already
tracked (warn: needs deliberate `git rm --cached`). Prefer committing the
updated `.gitignore`.

### 6. Report

Patterns added, files marked keep, remind to commit `.gitignore`.

## Rules

- Append-only `.gitignore`
- Baseline JSON stays local (listed in ignore rules)
- Keep sections clearly commented

## Related skills

- `git-issue` / `git-worktree` — when agent output appears during issue work
