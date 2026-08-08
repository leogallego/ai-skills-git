---
name: git-sandbox
description: >-
  Routes git and forge API operations under restricted sandboxes that block
  AF_UNIX sockets and keyring access. Use when gh auth fails, GPG signing
  fails, git push stalls in sandbox, credential errors appear, or choosing
  between git CLI and the active forge provider (default GitHub MCP). Does not
  own worktree creation (see git-worktree) or issue process (see git-issue).
license: Apache-2.0
compatibility: >-
  Agentskills.io clients (Cursor, Claude Code, …). Optional Lola install.
metadata:
  author: Leonardo Gallego
  version: "1.4.0"
  collection: sandbox
---

# git-sandbox

## Overview

Restricted sandboxes often block `AF_UNIX` sockets. That breaks `gh` (keyring
via D-Bus) and SSH agents, while **git over SSH** and authenticated **forge
API** channels (default: **GitHub MCP**) still work. Use **git CLI** for local
ops + transport; use the **active forge provider** for issue/PR/MR API ops.
Avoid `gh` when the keyring is unreachable.

**Forge provider** (resolve below). Unknown / unsupported → **STOP** before API
calls; git fetch/commit/push may still proceed.

Isolation and issue workflow live elsewhere: load `git-worktree` / `git-issue`.
Verify close keywords with `git-closes`.

## When to use / not

**Use when:** sandbox or similar restricted env; `gh` 401 / empty token; GPG
sign failures (`gpg-agent`, `Permission denied` under `~/.gnupg`); push stalls;
choosing tools for commit/push/PR.

**Not when:** unrestricted host where `gh` and git both work — normal tooling is
fine. Not a substitute for `git-worktree`.

## Instructions

### Resolve forge provider

1. `.git-pipeline.yml` → `forge.provider` if set  
2. Else infer from issue/MR/PR URL or **base-remote** host/path:
   - GitHub → `github`
   - Host/`gitlab.` or `/-/issues/` / `/-/merge_requests/` → `gitlab`
   - `gitea` / `forgejo` in host, or non-GH/GL forge with `/issues/` `/pulls/`
     → `gitea` or `forgejo` (ask if ambiguous)
3. Else default **`github`**
4. Report briefly: `forge.provider=…` (+ host if non-default)

| Provider | Load | API tools |
|----------|------|-----------|
| `github` | (default) | GitHub MCP; `gh` only if keyring works |
| `gitlab` | [forge-gitlab.md](forge-gitlab.md) | `glab` and/or GitLab API / token env |
| `gitea` / `forgejo` | [forge-gitea.md](forge-gitea.md) | `tea` and/or REST `/api/v1` + token |
| `none` / unknown | — | STOP API; git-only OK |

### Tool selection

| Operation | Tool | Why |
|-----------|------|-----|
| commit / branch / diff / log / status | git CLI | Local (any forge) |
| push / pull / fetch | git CLI (SSH remote) | Avoid HTTPS + broken helpers |
| create/list/merge PRs/MRs, issues, reviews, search | **Active forge provider** (table above) | Own auth channel |
| `gh` CLI | Avoid in sandbox; GitHub-only | Keyring / wrong forge |

### Why `gh` fails

`gh` reads its OAuth token from a keyring over D-Bus (`AF_UNIX`). Sandbox blocks
those sockets → empty `Authorization` header → 401. The token is usually fine;
`gh` simply cannot read it.

### Required setup (project / user)

1. **Remote URL must be SSH** (not HTTPS), e.g. `git@github.com:owner/repo.git`
   or `git@gitlab.example:group/repo.git`. If `git remote set-url` cannot lock
   `.git/config`, edit the config file with the editor tool instead.
2. **Allowlist** the forge host (and API host if needed) in the sandbox network
   settings — not only `github.com`.
3. **Permit** git write commands in the host’s permission allowlist when
   required (`git commit`, `git push`, `git pull`, `git fetch`).
4. **Commit signing — use SSH, not GPG** (see [Commit signing](#commit-signing-ssh-not-gpg) below).

### Commit signing (SSH, not GPG)

Sandboxes break **GPG** signing. They usually still allow **SSH** signing from
a key **file** (no `ssh-agent` required).

**Why GPG fails**

| Failure | Cause |
|---------|--------|
| `gpg: can't connect to the gpg-agent` / `No agent running` | Agent needs `AF_UNIX` (blocked) |
| `Permission denied` under `~/.gnupg/` (lock / `pubring.kbx`) | GnuPG home not writable in sandbox |
| `INV_SGNR` / `gpg failed to sign the data` | Same — signer cannot run |
| Global `user.signingKey=HEX_GPG_KEY_ID` + default `gpg.format` (openpgp) | Git tries GPG even when an SSH key exists |

**Never** “fix” this with `--no-gpg-sign`, `-c commit.gpgsign=false`, or
`--no-verify`. Use SSH signing instead.

**Pick the SSH key**

Prefer the same key used for GitHub transport:

```bash
grep -A3 -i 'host github.com' ~/.ssh/config
# use the IdentityFile path (e.g. ~/.ssh/id_rsa_redfedora)
```

If unset, use the key the user names for GitHub. Prefer an **absolute** path in
`user.signingKey` (tilde expansion is unreliable in some git/sandbox paths).

**Configure the repo (preferred)**

If `git config` cannot lock `.git/config`, edit it with the editor tool:

```gitconfig
[gpg]
	format = ssh
[user]
	signingKey = /home/USER/.ssh/YOUR_GITHUB_KEY
[commit]
	gpgsign = true
```

Scope: **this repo** (`.git/config`) unless the user asks for global change.

**Per-commit override** (when local config is still GPG):

```bash
git -c gpg.format=ssh \
    -c user.signingKey=/home/USER/.ssh/YOUR_GITHUB_KEY \
    -c commit.gpgsign=true \
    commit -m "message"
```

**Checks**

```bash
# Key can sign without an agent
ssh-keygen -Y sign -f /home/USER/.ssh/YOUR_GITHUB_KEY -n file /tmp/ssh-sign-test.txt

# After commit: look for "Good signature" / SSH signature block
git log -1 --show-signature
```

`git verify-commit` for SSH may need `gpg.ssh.allowedSignersFile`; signing can
still succeed when verify is not fully configured.

**GitHub “Verified”**

The public key must be added in GitHub as a **Signing** key (authentication-only
keys do not verify commits). Same key may be added once for auth and once for
signing if the UI requires it.

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
primary checkout from another agent — see **`git-pr`** (single-PR merge) and
**`git-pipeline`** §6 (sequential stack merge / retarget). In a worktree that
tracks the default branch: `git pull`. Otherwise `git fetch` and leave other
agents’ checkouts alone.

## Failure modes

| Error | Cause | Fix |
|-------|-------|-----|
| `could not read Username for 'https://github.com'` | HTTPS remote | Switch remote to SSH |
| `Error connecting to agent: Operation not permitted` | SSH agent socket blocked | Use key files directly (no agent) |
| `The token in default is invalid` (`gh`) | Keyring unread | Use GitHub MCP |
| `could not lock config file .git/config` | Atomic write blocked | Edit `.git/config` via editor tool |
| `Could not resolve hostname github.com` | Host not allowlisted | Add to sandbox allowlist |
| `gpg: can't connect to the gpg-agent` / `No agent running` | GPG needs AF_UNIX agent | SSH signing (`gpg.format=ssh` + key file) |
| `Permission denied` under `~/.gnupg/` | GnuPG home locked/unwritable | SSH signing; do not skip `gpgsign` |
| `gpg failed to sign the data` / `INV_SGNR` | GPG signer unavailable | Same — SSH key file via `-c` or `.git/config` |
| Commit signed but GitHub not “Verified” | Key is auth-only on GitHub | Add the pubkey as a **Signing** key |
| `Error connecting to agent` (SSH) | `ssh-agent` socket blocked | Use `IdentityFile` / signingKey path directly |
| `git push` stalls, no output | Permission prompt | Main session + allowlist + foreground |

## Related skills

- `git-worktree` — isolation mechanics
- `git-issue` / `git-pipeline` — workflow entries
- `git-pr` — push / PR/MR / merge-via-API
- `git-closes` — verify issue numbers before Closes/Fixes
- [forge-gitlab.md](forge-gitlab.md) — GitLab provider details
- [forge-gitea.md](forge-gitea.md) — Gitea / Forgejo provider details
