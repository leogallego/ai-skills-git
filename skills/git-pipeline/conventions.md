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
labels: true          # pipeline/* labels
attribution: "Assisted-by: …"
test_commands: []
lint_commands: []
always_load_review_skills: []
claude_md_hash: ""
```

`git-issue` loads this file when present; full infer/confirm is
`git-pipeline`’s job.
