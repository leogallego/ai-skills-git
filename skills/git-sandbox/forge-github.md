# Forge provider: GitHub

Use when `forge.provider` is **`github`** (default), or when inferred from
`github.com` / GitHub issue-PR URLs. Load **only** this file for GitHub API
details — not `forge-gitlab.md` / `forge-gitea.md`.

## Detect

1. `.git-pipeline.yml` → `forge.provider: github`
2. Issue/PR URL or base-remote host is `github.com` (or clearly GitHub Enterprise
   if the user says so)
3. Default when unset and no other forge matched

```yaml
forge:
  provider: github
```

## Auth (sandbox-aware)

| Channel | When | Notes |
|---------|------|--------|
| **GitHub MCP** | Sandbox / broken keyring | Prefer — own auth channel |
| **`gh` CLI** | Keyring works (unrestricted host) | Avoid in sandbox (see below) |

### Why `gh` fails in sandbox

`gh` reads its OAuth token from a keyring over D-Bus (`AF_UNIX`). Sandbox blocks
those sockets → empty `Authorization` header → 401. The token is usually fine;
`gh` simply cannot read it. Use GitHub MCP instead.

## Operations → tools

| Op | Prefer | Fallback |
|----|--------|----------|
| Fetch issue | GitHub MCP `issue_read` | `gh issue view` if keyring works |
| Comment / labels | GitHub MCP | `gh` |
| Create PR | GitHub MCP `create_pull_request` | `gh pr create` |
| PR body / close keywords | `git-closes` | |
| Merge PR | GitHub MCP `merge_pull_request` | `gh pr merge` — **merge via API** when primary holds default |
| Delete branch | After merge if appropriate | |

Stacked PRs: `stack_ci: serial` — rebase onto new default after each merge.

## Close keywords

GitHub auto-close grammar — see `git-closes` (negation does not disable matches).

## Commit “Verified” on GitHub

SSH-signed commits show **Verified** only if the public key is added as a
**Signing** key (auth-only keys do not count). Same key may be added once for
auth and once for signing if the UI requires it. Signing mechanics themselves
are in `git-sandbox` (SSH, not GPG).

## Failure modes (GitHub-specific)

| Error | Cause | Fix |
|-------|-------|-----|
| `could not read Username for 'https://github.com'` | HTTPS remote | Switch remote to SSH |
| `The token in default is invalid` (`gh`) | Keyring unread | Use GitHub MCP |
| `Could not resolve hostname github.com` | Host not allowlisted | Allowlist `github.com` (+ API) |
| Commit signed but not “Verified” | Key is auth-only | Add pubkey as **Signing** key |

## Operator dry-run

Default path on this pack’s own GitHub repo: `git-issue` / `git-pipeline` with
MCP merge while primary holds `main`.
