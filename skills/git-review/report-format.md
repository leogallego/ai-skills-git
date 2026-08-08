# Architecture review report

```markdown
## Architecture Review — <branch or PR #N — title>

### Contracts

- **Path:** <resolved contracts path>
- **Extras loaded:** <adr_dir / strategy / provider or none>
- **Companions:** <skill names or none>

### Contract violations (must-fix)

- **[AREA]** `path:line` — <what>. <rule cite>. <fix>.

(If none: _None._)

### Recommendations (consider)

- **[AREA]** `path:line` — <what>. <why>. <suggestion>.

(If none: _None._)

### Info

- <bootstrap notes, self-update hints, unmapped files, coverage limits>

### Verdict

One of:
- **Clean** — no hard violations
- **Fixable** — N hard, M soft
- **Needs architecture discussion** — structural / contracts change / unclear rules
- **Skipped — no contracts** — bootstrap declined or blocked
```

AREA examples: `LAYER`, `INTERFACE`, `MODULE`, `STATE`, `DI`, `SECURITY`,
`NAMING`, `SIZE`, `ADR`, `CONTRACTS`. Use IDs from the contracts doc when present.

### Severity (per finding)

| Report label | Meaning | Action | Finding `severity` (implement/pr) |
|--------------|---------|--------|-------------------------------------|
| Error / must-fix | Hard rule violation | Block architecture angle until fixed | `critical` |
| Warning / consider | Soft guideline | Fix or justify / file follow-up | `warning` |
| Info | Note, draft, self-update | No merge block alone | `info` |

Human-facing report uses Error/Warning/Info + Verdict. Pipeline fix loops use
the Finding `severity` column so architecture matches code-quality / security
/ skill-compliance aggregation.
