#!/usr/bin/env bash
# Install this pack's skills for multi-agent use.
#
# Canonical (agentskills.io cross-client): ~/.agents/skills/<name>
# Optional mirrors when those trees already exist:
#   ~/.cursor/skills/<name>
#   ~/.claude/skills/<name>
#
# Override destinations:
#   AGENTS_SKILLS_DIR   default: ~/.agents/skills
#   ALSO_MIRROR=0       skip cursor/claude mirrors
#   CURSOR_SKILLS_DIR   default: ~/.cursor/skills
#   CLAUDE_SKILLS_DIR   default: ~/.claude/skills
#
# Also see: npx skills add <this-repo> -g --all
# (vercel-labs/skills CLI — installs into .agents/skills and agent dirs)
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_SRC="${REPO_ROOT}/skills"
AGENTS_DEST="${AGENTS_SKILLS_DIR:-${HOME}/.agents/skills}"
CURSOR_DEST="${CURSOR_SKILLS_DIR:-${HOME}/.cursor/skills}"
CLAUDE_DEST="${CLAUDE_SKILLS_DIR:-${HOME}/.claude/skills}"
ALSO_MIRROR="${ALSO_MIRROR:-1}"

if [[ ! -d "${SKILLS_SRC}" ]]; then
  echo "error: skills directory not found: ${SKILLS_SRC}" >&2
  exit 1
fi

link_skill() {
  local dest_root="$1"
  local name="$2"
  local src="$3"
  mkdir -p "${dest_root}"
  ln -sfn "${src}" "${dest_root}/${name}"
  echo "linked ${dest_root}/${name} -> ${src}"
}

count=0
names=()
for d in "${SKILLS_SRC}"/*/; do
  [[ -d "${d}" ]] || continue
  name="$(basename "${d}")"
  if [[ ! -f "${d}/SKILL.md" ]]; then
    echo "skip: ${name} (no SKILL.md)" >&2
    continue
  fi
  src="${d%/}"
  link_skill "${AGENTS_DEST}" "${name}" "${src}"
  if [[ "${ALSO_MIRROR}" == "1" ]]; then
    # Only mirror into agent trees that already exist (or create cursor/claude
    # when the user clearly uses them — create if parent ~/.cursor or ~/.claude exists).
    if [[ -d "${HOME}/.cursor" ]]; then
      link_skill "${CURSOR_DEST}" "${name}" "${src}"
    fi
    if [[ -d "${HOME}/.claude" ]]; then
      link_skill "${CLAUDE_DEST}" "${name}" "${src}"
    fi
  fi
  names+=("${name}")
  count=$((count + 1))
done

echo "OK: ${count} skill(s) linked into ${AGENTS_DEST}"
if [[ "${ALSO_MIRROR}" == "1" ]]; then
  echo "Mirrors: ~/.cursor/skills and/or ~/.claude/skills when those agents are present."
fi
echo "Start a new agent session so skills reload."
echo "Tip: npx skills add ${REPO_ROOT} -g --all   # alternative multi-agent installer"
