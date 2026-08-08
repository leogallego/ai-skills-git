# Architecture Service Contracts

Enforceable rules for this repository. Reviewed by `git-review`
(ai-skills-git). **Hard rules** must be fixed before merge. **Soft guidelines**
are advisory.

## Layer map

| Path / pattern | Layer |
|----------------|-------|
| TODO | TODO |

## Dependency rules

- Higher layers may depend on lower layers only.
- TODO: list allowed edges and forbidden shortcuts (no layer skipping, no
  upward imports, …).

```text
TODO: LayerN → … → Layer1
```

## Hard rules

- [ ] TODO — imports / layer discipline
- [ ] TODO — module or package boundaries
- [ ] TODO — interfaces / DI registration (if applicable)
- [ ] TODO — state exposure (if applicable)
- [ ] TODO — secrets / credential handling at boundaries

## Soft guidelines

- [ ] TODO — file size threshold and named exceptions
- [ ] TODO — naming patterns
- [ ] TODO — extraction signals (fat constructors, mixed helpers)

## Known exceptions

| ID | Summary | Status |
|----|---------|--------|
| — | — | — |

## Companion skills (optional)

| When files match | Load skill (if installed) |
|------------------|---------------------------|
| TODO | TODO |

## Notes

- Keep this file as the source of truth. Do not duplicate hard rules into a
  project `pr-architecture-review` skill.
- Optional: ADRs under `docs/architecture/adr/`; point
  `.git-pipeline.yml` → `architecture.adr_dir` when used.
