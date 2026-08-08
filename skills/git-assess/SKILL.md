---
name: git-assess
description: >-
  Assess a GitHub issue against the current codebase: re-read issue payload,
  verify references, estimate scope, map skills, record out-of-scope exclusions,
  comment/label when appropriate. Use during git-issue or git-pipeline after
  remotes are verified and an issue payload exists (or fetch if missing).
license: Apache-2.0
compatibility: >-
  Agentskills.io clients (Cursor, Claude Code, …). Optional Lola install.
metadata:
  author: Leonardo Gallego
  version: "1.1.1"
  collection: workflow
---

# git-assess

## Overview

Phase skill: analysis + optional issue trail. Does not create worktrees or PRs.
Tool choice for GitHub API: `git-sandbox`. Remotes: `git-worktree` §0.

Adapted from `issue-pipeline-skill` Phases 1–2 (Apache-2.0). See pack `NOTICE`.

## When to use / not

**Use when:** called from `git-issue` / `git-pipeline` with an issue number or
payload.

**Not when:** only remotes/worktree → `git-worktree`.

## Instructions

### 1. Payload and remotes

1. Prefer the issue payload from the entry. If missing, fetch via MCP/`gh`
   (`git-sandbox`): title, body, labels, state, number.
2. If remotes were not verified this session, run `git-worktree` §0 first.
3. Confirm issue `owner/repo` matches **base-remote**. Mismatch → STOP.

### 2. Re-read issue

Identify acceptance criteria, ambiguities, referenced files/APIs, referenced PRs.

### 3. Codebase verification

For each cited file/class/API: exists? problem still present? compatible?

If the caller is mid-chain, verify against the chain base branch (not only
default branch).

Significant premise invalid → **skip**: comment why, return
`codebase_still_matches: false`. Minor renames → note and adapt.

### 4. Scope

| Scope | Criteria |
|-------|----------|
| trivial | Single file, under 50 lines, no new tests |
| small | 2–5 files, under 200 lines, straightforward tests |
| medium | 5–15 files, new module or significant refactor |
| large | 15+ files, architectural changes, multiple test types |

### 5. Skill mapping (local, stack-relevant + config overrides)

**Goal:** load skills that help *this* repo and issue — not every skill on the
machine. Index both **user** and **project** installs; select by stack unless
the project config explicitly names a skill.

1. **Discover locally available skills** (union of **project + user**; skip
   missing roots — same skill `name` once is enough; prefer project path if
   both exist):
   - **Project:** `**/skills/*/SKILL.md`, `.cursor/skills/**`, `.claude/skills/**`
   - **User/host:** `~/.cursor/skills/**`, `~/.claude/skills/**` (follow
     symlinks; use the target `SKILL.md`)
   - Other agent skill roots the host documents (Lola, Claude plugins, …)
2. **Index lightly:** frontmatter `name` + `description` (first ~15–30 lines).
   Do not hardcode pack names or language lists as required installs.
3. **Infer project stack** from foundation/manifests (examples, not exclusive):
   - Python → `pyproject.toml` / `setup.cfg` / `requirements*.txt`
   - Kotlin / Android → `*.gradle*` / `settings.gradle*` / `AndroidManifest.xml`
   - TypeScript/JS → `package.json` / `tsconfig*.json`
   - Go / Rust → `go.mod` / `Cargo.toml`
   - Plus paths the issue will touch
4. **Select `skills_needed` (auto):** match index entries whose
   descriptions/names fit the stack **and** likely touched paths (e.g. Python
   style/testing skills on a Python change; Kotlin/Android skills on Android
   UI). Prefer fewer, on-point skills — do **not** auto-load unrelated
   ecosystems just because they are installed.
5. **`always_load_review_skills` (manual config wins):** for each name listed
   in `.git-pipeline.yml`, if that skill exists in the local index (user or
   project), **always** add it to `skills_needed` — even when it looks
   off-stack. Missing name → note in assess output; do not invent a skill.
   Example: Python repo with `always_load_review_skills: [pep8-review]` →
   always load `pep8-review` when installed; a mistaken
   `pf-component-check` entry would still load if present (operator chose it).
6. Record the chosen names (and briefly why: auto vs config) for `git-plan` /
   `git-implement`.

### 6. On-demand context

- Keyword-match architecture/specs/plans/memory if present (discover paths;
  do not require `docs/superpowers/`).
- Read explicit paths quoted in the issue body.
- For referenced merged PRs, fetch diffs via MCP/`gh` (`git-sandbox`).

### 7. Risks

Flag security/auth, public API, CI/CD, and test-breakage risks.

### 8. Out of scope

Related issue numbers in the body that are **not** in the caller’s input list →
`out_of_scope` for implementers.

### 9. Output

```text
Assessment:
  codebase_still_matches: true|false
  scope: trivial|small|medium|large
  files_to_modify: […]
  skills_needed: […]
  on_demand_context_loaded: […]
  risks: […]
  blockers_found: […]
  out_of_scope: […]
  brief: <short goal summary for implement/PR>
```

### 10. Update issue (optional trail)

When labels are enabled (`.git-pipeline.yml` or caller default):

1. Comment with [assessment-comment.md](assessment-comment.md).
2. Append factual corrections to the issue body only if needed (do not rewrite).
3. Add `pipeline/in-progress` (create label if missing: `#0E8A16`).

## Related skills

- `git-issue`, `git-pipeline` — callers
- `git-plan`, `git-implement` — next
- `git-worktree`, `git-sandbox`
