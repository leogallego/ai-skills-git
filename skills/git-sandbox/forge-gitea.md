# Forge provider: Gitea / Forgejo

Use when `forge.provider` is **`gitea`** or **`forgejo`**, or when inferred
from the base-remote / issue URL (below). Forgejo is API-compatible with Gitea
for the ops in this pack — treat them the same unless a host docs a difference.

Plain git (fetch/worktree/commit/push) is unchanged — this file covers
**issue + pull-request API** only.

## Detect

Resolve in order (first match wins):

1. `.git-pipeline.yml` → `forge.provider: gitea` or `forgejo`
2. Issue / PR URL or base-remote host suggests Gitea/Forgejo:
   - Path `/issues/` or `/pulls/` on a non-GitHub, non-GitLab host
   - Hostnames containing `gitea`, `forgejo`, or a known private forge host
     listed in `forge.host`
3. Explicit config beats weak URL guesses — if unsure, **STOP** and ask
   (`github` / `gitlab` / `gitea` / `forgejo`)

```yaml
forge:
  provider: gitea   # or forgejo
  host: git.example.com
  # api_base: https://git.example.com/api/v1
```

`owner/repo` is usually the last two path segments of the SSH/HTTPS remote
(strip `.git`). Custom root paths still map to `owner/repo` for the API.

## Auth (sandbox-aware)

| Channel | When | Notes |
|---------|------|--------|
| **`tea` CLI** | Installed + logged in | Prefer when it works outside sandbox keyring issues |
| **Token env / file** | Sandbox or headless | `GITEA_TOKEN` / `FORGEJO_TOKEN` (or host-documented equivalent); token file path from user config — never print secrets |
| **REST** | Always available fallback | `Authorization: token <token>` against `/api/v1` |

SSH remotes for git transport. **Allowlist the custom host** (and API host if
different) in sandbox network settings — not only `github.com`.

## Operations → tools

| Op | Prefer | Fallback |
|----|--------|----------|
| Fetch issue | `tea issues view <N>` / API `GET /api/v1/repos/{owner}/{repo}/issues/{index}` | |
| Comment | API issue comments | |
| Create PR | `tea pulls create` — head = push branch, base = default or stack parent | `POST …/pulls` |
| PR body / close keywords | Follow `git-closes` | |
| Merge PR | `tea pulls merge` or API merge | **Merge via API** when primary holds default branch |
| Delete branch | After merge if appropriate | |

Stacked PRs: same `stack_ci: serial` rules as GitHub/GitLab — rebase onto new
default after each merge; ignore pre-rebase CI greens.

## Close keywords

Gitea/Forgejo commonly honor `Closes` / `Fixes` with `#N` (confirm on the
host version). Apply `git-closes` safe wording — never “Does not close #N”.
Verify the issue via API before close keywords.

## Merge-via-API

If local merge/checkout is blocked because another worktree holds the default
branch: merge the PR via API/`tea` — do not reset primary. Then `git fetch`
and sync only a safe worktree.

## Operator dry-run checklist

Against local Gitea, LAN Forgejo, or a public Forgejo instance you control:

1. Point a remote at the forge; set `forge.provider: gitea` or `forgejo`
2. Allowlist the host in sandbox network settings
3. `git-issue <n>` → worktree → one PR from default
4. Confirm tools used `tea`/REST (not `gh` / GitHub MCP)
5. Merge via API while primary stays on default
