#!/usr/bin/env bash
# Symlink this repo's skills into ~/.cursor/skills/ for native Cursor Agent Skills.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_SRC="${REPO_ROOT}/skills"
DEST="${CURSOR_SKILLS_DIR:-${HOME}/.cursor/skills}"

if [[ ! -d "${SKILLS_SRC}" ]]; then
  echo "error: skills directory not found: ${SKILLS_SRC}" >&2
  exit 1
fi

mkdir -p "${DEST}"

count=0
for d in "${SKILLS_SRC}"/*/; do
  [[ -d "${d}" ]] || continue
  name="$(basename "${d}")"
  if [[ ! -f "${d}/SKILL.md" ]]; then
    echo "skip: ${name} (no SKILL.md)" >&2
    continue
  fi
  ln -sfn "${d%/}" "${DEST}/${name}"
  echo "linked ${DEST}/${name} -> ${d%/}"
  count=$((count + 1))
done

echo "OK: ${count} skill(s) linked into ${DEST}"
echo "Start a new Cursor chat so the skills are picked up."
