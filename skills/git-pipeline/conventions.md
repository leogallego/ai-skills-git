# Project conventions (`.git-pipeline.yml`)

## Load

1. If `.git-pipeline.yml` exists → load and merge into foundation. Also accept
   legacy `.issue-pipeline.yml` (read-only migrate: write `.git-pipeline.yml`
   on next confirm).
2. If `claude_md_hash` (or equivalent) changed since save → re-run conflict
   detection only.

## First run (no config)

**A — Intent:** extract rules from project instructions (architecture, naming,
tests, security, attribution, always-load review skills).

**B — Reality:** infer from code/manifests (stack, layers, test framework,
commit style, lint/test commands).

**C — Merge:** confirmed / conflict / inferred / undetermined.

**D — Confirm with user:** resolve conflicts; accept or skip inferences.

**E — Save** `.git-pipeline.yml` (commit with the team unless user gitignores it).

Suggested keys (extend as needed):

```yaml
# git-pipeline conventions — user-confirmed
version: 1
default_branch: main
branch_pattern: "<type>/<n>-<slug>"
merge_method: merge   # or squash | rebase | detect
# Stacked PRs + expensive CI: prefer serial (one CI-active PR at a time).
# parallel = open full stack for review; expect rebuilds after each merge.
stack_ci: serial      # serial | parallel
labels: true          # pipeline/* labels
attribution: "Assisted-by: …"
test_commands: []
lint_commands: []
# Manual overrides: skill names always added to skills_needed when found
# in the local index (user or project). Config wins — not stack-filtered.
# Example (Python team that always wants PEP8 review when the skill exists):
#   always_load_review_skills: [pep8-review]
always_load_review_skills: []
claude_md_hash: ""
# Tracker / PR API (default github). Plain git stays forge-agnostic.
forge:
  provider: github   # github | gitlab | gitea | forgejo | none
  # host / API base: omit to infer from base-remote URL when possible
```

**`always_load_review_skills`:** operator-chosen list. `git-assess` must load
each name that exists under project or user skill roots, **even if** it does
not match the inferred stack. Auto-matched skills stay stack-filtered; only
this list bypasses that filter. Do not list every installed pack — only what
you intend to force.

**`stack_ci`:** how stacked PRs interact with CI (see `git-pipeline` §4).
Default when unset: **`serial`** — only one ready/non-draft PR runs CI at a
time; after merge, rebase the next onto the new default, push, wait for green,
then merge. Set **`parallel`** only when simultaneous review of the whole
stack is worth the rebuild cost.

**`forge.provider`:** selects the issue/PR (or MR) API adapter used by
`git-issue` / `git-pipeline` / `git-pr` / `git-closes` / `git-sandbox`. Default
when unset: **`github`**. `none` = git-only (STOP before issue/PR API steps).
Unsupported or unknown provider → **STOP** and report what still works
(remotes/worktree/commit/push). **`gitlab`:** see `git-sandbox` /
`forge-gitlab.md`. **`gitea` / `forgejo`:** Related to #4.

`git-issue` loads this file when present; full infer/confirm is
`git-pipeline`’s job.
