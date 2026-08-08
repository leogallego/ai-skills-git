---
name: git-sandbox
description: >-
  Routes git and forge API operations under restricted sandboxes that block
  AF_UNIX sockets and keyring access. Use when CLI auth fails, GPG signing
  fails, git push stalls in sandbox, credential errors appear, or choosing
  between git CLI and the active forge provider. Does not own worktree
  creation (see git-worktree) or issue process (see git-issue).
license: Apache-2.0
compatibility: >-
  Agentskills.io clients (Cursor, Claude Code, …). Optional Lola install.
metadata:
  author: Leonardo Gallego
  version: "1.5.0"
  collection: sandbox
---

# git-sandbox

## Overview

Restricted sandboxes often block `AF_UNIX` sockets. That breaks keyring-backed
CLIs and SSH agents, while **git over SSH** and authenticated **forge API**
channels (MCP / token env) still work. Use **git CLI** for local ops +
transport; use the **active forge provider** for issue/PR/MR API ops.

**Forge provider** (resolve below) — then load **only** that provider’s helper
file. Do not load other `forge-*.md` files.

Unknown / unsupported → **STOP** before API calls; git fetch/commit/push may
still proceed.

Isolation and issue workflow: `git-worktree` / `git-issue`. Close keywords:
`git-closes`.

## When to use / not

**Use when:** sandbox or similar restricted env; forge CLI 401 / empty token;
GPG sign failures; push stalls; choosing tools for commit/push/PR/MR.

**Not when:** unrestricted host where the forge CLI and git both work — normal
tooling is fine. Not a substitute for `git-worktree`.

## Instructions

### Resolve forge provider

1. `.git-pipeline.yml` → `forge.provider` if set  
2. Else infer from issue/MR/PR URL or **base-remote** host/path:
   - GitHub → `github`
   - Host/`gitlab.` or `/-/issues/` / `/-/merge_requests/` → `gitlab`
   - `gitea` / `forgejo` in host, or non-GH/GL forge with `/issues/` `/pulls/`
     → `gitea` or `forgejo` (ask if ambiguous)
3. Else default **`github`**
4. Report: `forge.provider=…` (+ host if non-default)
5. **Read only** the matching helper below — skip the others

| Provider | Load (this skill dir) | Typical API tools |
|----------|------------------------|-------------------|
| `github` | [forge-github.md](forge-github.md) | GitHub MCP; `gh` if keyring works |
| `gitlab` | [forge-gitlab.md](forge-gitlab.md) | `glab` / GitLab API / token env |
| `gitea` / `forgejo` | [forge-gitea.md](forge-gitea.md) | `tea` / REST `/api/v1` + token |
| `none` / unknown | — | STOP API; git-only OK |

### Tool selection (shared)

| Operation | Tool | Why |
|-----------|------|-----|
| commit / branch / diff / log / status | git CLI | Local (any forge) |
| push / pull / fetch | git CLI (SSH remote) | Avoid HTTPS + broken helpers |
| create/list/merge PRs/MRs, issues, reviews, search | **Active forge helper** | Own auth channel |

### Required setup (project / user)

1. **Remote URL must be SSH** (not HTTPS), e.g. `git@HOST:owner/repo.git`.
   If `git remote set-url` cannot lock `.git/config`, edit the config file with
   the editor tool instead.
2. **Allowlist** the forge host (and API host if needed) in the sandbox network
   settings.
3. **Permit** git write commands when required (`git commit`, `git push`,
   `git pull`, `git fetch`).
4. **Commit signing — use SSH, not GPG** (below).

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

Prefer the same key used for the forge transport:

```bash
grep -A3 -i 'host YOUR_FORGE_HOST' ~/.ssh/config
# use the IdentityFile path (absolute path preferred)
```

**Configure the repo (preferred)**

If `git config` cannot lock `.git/config`, edit it with the editor tool:

```gitconfig
[gpg]
	format = ssh
[user]
	signingKey = /home/USER/.ssh/YOUR_FORGE_KEY
[commit]
	gpgsign = true
```

Scope: **this repo** unless the user asks for global change.

**Per-commit override** (when local config is still GPG):

```bash
git -c gpg.format=ssh \
    -c user.signingKey=/home/USER/.ssh/YOUR_FORGE_KEY \
    -c commit.gpgsign=true \
    commit -m "message"
```

**Checks**

```bash
ssh-keygen -Y sign -f /home/USER/.ssh/YOUR_FORGE_KEY -n file /tmp/ssh-sign-test.txt
git log -1 --show-signature
```

`git verify-commit` for SSH may need `gpg.ssh.allowedSignersFile`; signing can
still succeed when verify is not fully configured.

Host-specific “Verified” badges (e.g. GitHub Signing keys) → that forge’s
helper file.

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
primary checkout — see **`git-pr`** and **`git-pipeline`** §6. In a worktree
that tracks the default branch: `git pull`. Otherwise `git fetch` and leave
other agents’ checkouts alone.

## Failure modes (shared)

| Error | Cause | Fix |
|-------|-------|-----|
| HTTPS auth / username prompt | HTTPS remote | Switch remote to SSH |
| `Error connecting to agent: Operation not permitted` | SSH agent socket blocked | Use key files directly (no agent) |
| `could not lock config file .git/config` | Atomic write blocked | Edit `.git/config` via editor tool |
| `Could not resolve hostname …` | Host not allowlisted | Allowlist forge (+ API) host |
| `gpg: can't connect to the gpg-agent` / `No agent running` | GPG needs AF_UNIX | SSH signing |
| `Permission denied` under `~/.gnupg/` | GnuPG home locked | SSH signing; do not skip `gpgsign` |
| `gpg failed to sign the data` / `INV_SGNR` | GPG unavailable | SSH key via `-c` or `.git/config` |
| `git push` stalls, no output | Permission prompt | Main session + allowlist + foreground |

Forge-specific errors → that provider’s `forge-*.md`.

## Related skills

- `git-worktree` — isolation mechanics
- `git-issue` / `git-pipeline` — workflow entries
- `git-pr` — push / PR/MR / merge-via-API
- `git-closes` — verify issue numbers before Closes/Fixes
- Provider helpers (load **one**): [forge-github.md](forge-github.md),
  [forge-gitlab.md](forge-gitlab.md), [forge-gitea.md](forge-gitea.md)
