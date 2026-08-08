#!/usr/bin/env bash
# Validate every skill under skills/ against agentskills.io (skills-ref).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_SRC="${REPO_ROOT}/skills"

if [[ ! -d "${SKILLS_SRC}" ]]; then
  echo "error: skills directory not found: ${SKILLS_SRC}" >&2
  exit 1
fi

if ! command -v uvx >/dev/null 2>&1; then
  echo "error: uvx not found (install uv: https://docs.astral.sh/uv/)" >&2
  exit 1
fi

fail=0
count=0
for d in "${SKILLS_SRC}"/*/; do
  [[ -d "${d}" ]] || continue
  name="$(basename "${d}")"
  if [[ ! -f "${d}/SKILL.md" ]]; then
    echo "error: ${name}: missing SKILL.md" >&2
    fail=1
    continue
  fi
  if ! grep -q "^name: ${name}$" "${d}/SKILL.md"; then
    echo "error: ${name}: frontmatter name does not match directory" >&2
    fail=1
    continue
  fi
  echo "validate: ${name}"
  if ! uvx --from skills-ref agentskills validate "${d%/}"; then
    fail=1
  fi
  count=$((count + 1))
done

if [[ "${count}" -eq 0 ]]; then
  echo "error: no skill directories found under ${SKILLS_SRC}" >&2
  exit 1
fi

if [[ "${fail}" -ne 0 ]]; then
  echo "FAIL: one or more skills failed validation" >&2
  exit 1
fi

echo "OK: ${count} skill(s) passed agentskills validate + name↔directory check"
