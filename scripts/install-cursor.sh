#!/usr/bin/env bash
# Deprecated wrapper — prefer ./scripts/install-agents.sh
#
# Historically this only linked into ~/.cursor/skills/. Multi-agent installs
# should use the agentskills.io cross-client path (~/.agents/skills/) via
# install-agents.sh (which also mirrors to Cursor/Claude when present).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "note: install-cursor.sh is a compatibility wrapper; using install-agents.sh" >&2
exec "${REPO_ROOT}/scripts/install-agents.sh" "$@"
