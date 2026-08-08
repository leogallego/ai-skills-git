# Forge provider: GitLab

Use when `forge.provider` is **`gitlab`**, or when inferred from the
base-remote / issue URL (below). Load **only** this helper for GitLab API
details — not `forge-github.md` / `forge-gitea.md`. Plain git stays unchanged.

## Detect

Resolve provider in this order (first match wins):

1. `.git-pipeline.yml` → `forge.provider: gitlab`
2. Issue / MR URL host contains `gitlab.` (e.g. `gitlab.com`,
   `gitlab.example.com`) or path shaped like GitLab
   (`/-/issues/`, `/-/merge_requests/`)
3. Base-remote URL host matches the same patterns
4. Else do **not** assume GitLab

Optional config:

```yaml
forge:
  provider: gitlab
  # host: gitlab.example.com   # omit to infer from base-remote
  # api_base: https://gitlab.example.com/api/v4
```

Project path is GitLab `path_with_namespace` (e.g. `group/subgroup/repo`), not
always two segments. Map from the remote URL path (strip `.git`).

## Auth (sandbox-aware)

| Channel | When | Notes |
|---------|------|--------|
| **`glab`** | Host keyring works | Prefer for interactive hosts |
| **Env token** | Sandbox / broken keyring | `GITLAB_TOKEN` or `GLAB_TOKEN` with `api` scope; never print the token |
| **GitLab MCP / HTTP API** | If the host exposes one | Same ops as below |

Avoid HTTPS remotes that prompt for username/password in sandbox — use SSH
(`git@host:group/repo.git`) and allowlist the GitLab host + API host.

## Operations → tools

| Op | Prefer | Fallback |
|----|--------|----------|
| Fetch issue | `glab issue view <N> --repo <path>` JSON/API | `GET /api/v4/projects/:id/issues/:iid` |
| Comment on issue | `glab issue note` / API notes | |
| Create MR | `glab mr create` — source = push branch, target = base branch | `POST …/merge_requests` |
| MR body / close keywords | Same rules as `git-closes` (`Closes` / `Fixes` / `Related to`) | |
| List / wait CI | `glab ci status` / pipelines API | |
| Merge MR | `glab mr merge` (method from `.git-pipeline.yml` or GitLab project default) | API merge when primary holds default branch |
| Delete remote branch | After merge if appropriate | |

Stacked MRs: base = previous branch (or default after predecessor merges).
Apply `stack_ci: serial` the same as GitHub — rebase onto new default after
each merge; do not trust CI from before the rebase.

## Close keywords

GitLab honors `Closes` / `Fixes` / `Resolves` (+ variants) with `#N` or full
URLs similarly to GitHub. **Negation still unsafe** if the keyword+`#N`
pattern appears — follow `git-closes` safe wording (`Related to #N`,
`Partial progress on #N`).

Always verify the issue via API before `Closes`/`Fixes`.

## Merge-via-API

If merge fails because the default branch is checked out in another worktree:
merge the MR via API/`glab` — do not checkout/reset the primary repo. Then
`git fetch` and sync only a safe worktree.

## Operator dry-run checklist

On a tiny GitLab project you control:

1. Set `forge.provider: gitlab` (or use a `gitlab.com` remote)
2. `git-issue <n>` → worktree → one MR from default branch
3. Confirm issue fetch + MR create used `glab`/API (not `gh` / GitHub MCP)
4. Merge via API while primary stays on default
5. Confirm close keywords behaved as expected
