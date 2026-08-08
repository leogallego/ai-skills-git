---
name: git-sandbox
description: >-
  Routes git and GitHub operations under restricted sandboxes that block
  AF_UNIX sockets and keyring access. Use when gh auth fails, git push stalls
  in sandbox, credential errors appear, or choosing between git CLI, gh, and
  GitHub MCP. Does not own worktree creation (see git-worktree) or issue
  process (see git-issue).
license: Apache-2.0
compatibility: >-
  Agentskills.io clients (Cursor, Claude Code, …). Optional Lola install.
metadata:
  author: Leonardo Gallego
  version: "1.0.0"
  collection: sandbox
---

# git-sandbox

## Overview

Restricted sandboxes often block `AF_UNIX` sockets. That breaks `gh` (keyring
via D-Bus) and SSH agents, while **git over SSH** and **GitHub MCP** still work.
Use **git CLI** for local ops + transport; use **GitHub MCP** (or another
already-authenticated API channel) for PR/issue/API ops. Avoid `gh` when the
keyring is unreachable.

Isolation and issue workflow live elsewhere: load `git-worktree` / `git-issue`.
Verify `Closes #` with `git-closes`.

## When to use / not

**Use when:** sandbox or similar restricted env; `gh` 401 / empty token; push
stalls; choosing tools for commit/push/PR.

**Not when:** unrestricted host where `gh` and git both work — normal tooling is
fine. Not a substitute for `git-worktree`.

## Instructions

### Tool selection

| Operation | Tool | Why |
|-----------|------|-----|
| commit / branch / diff / log / status | git CLI | Local |
| push / pull / fetch | git CLI (SSH remote) | Avoid HTTPS + broken helpers |
| create/list/merge PRs, issues, reviews, search | GitHub MCP (or equivalent) | Own auth channel |
| `gh` CLI | Avoid in sandbox | Cannot read token from keyring |

### Why `gh` fails

`gh` reads its OAuth token from a keyring over D-Bus (`AF_UNIX`). Sandbox blocks
those sockets → empty `Authorization` header → 401. The token is usually fine;
`gh` simply cannot read it.

### Required setup (project / user)

1. **Remote URL must be SSH** (not HTTPS), e.g. `git@github.com:owner/repo.git`.
   If `git remote set-url` cannot lock `.git/config`, edit the config file with
   the editor tool instead.
2. **Allowlist** `github.com` (and API host if needed) in the sandbox network
   settings for the host product.
3. **Permit** git write commands in the host’s permission allowlist when
   required (`git commit`, `git push`, `git pull`, `git fetch`).
4. **Signing:** GPG agent sockets often fail. Prefer **SSH commit signing**.
   Never skip signing with `--no-gpg-sign` / `commit.gpgsign=false` when SSH
   signing is available.

```bash
# Example per-commit SSH sign (adjust key path)
git -c gpg.format=ssh \
    -c user.signingKey=~/.ssh/YOUR_KEY \
    -c commit.gpgsign=true \
    commit -m "message"
```

### Push stalls

Especially from **subagents**: push may hang on a permission prompt the
subagent cannot surface.

1. Do not `git push` from subagents — return to the main session.
2. Ensure Bash/git push permissions are allowlisted.
3. Run push in the foreground so prompts are visible.
4. Last resort (interactive sessions only): disable sandbox for that command if
   the host supports it and the user is present. Never do this unattended.

### After API merge

MCP/API merge does not update local files. Sync safely without stealing the
primary checkout from another agent — see `git-issue` merge steps. In a
worktree that tracks the default branch: `git pull`. Otherwise `git fetch` and
leave other agents’ checkouts alone.

## Failure modes

| Error | Cause | Fix |
|-------|-------|-----|
| `could not read Username for 'https://github.com'` | HTTPS remote | Switch remote to SSH |
| `Error connecting to agent: Operation not permitted` | SSH agent socket blocked | Use key files directly (no agent) |
| `The token in default is invalid` (`gh`) | Keyring unread | Use GitHub MCP |
| `could not lock config file .git/config` | Atomic write blocked | Edit `.git/config` via editor tool |
| `Could not resolve hostname github.com` | Host not allowlisted | Add to sandbox allowlist |
| `gpg: can't connect to the gpg-agent` | GPG socket / read-only gnupg | SSH signing; never skip signing |
| `git push` stalls, no output | Permission prompt | Main session + allowlist + foreground |

## Related skills

- `git-worktree` — isolation mechanics
- `git-issue` — multi-agent issue process
- `git-closes` — verify issue numbers before Closes/Fixes
