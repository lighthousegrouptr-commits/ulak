# 2026-05-31 — Full Refresh + Deploy Run 4

**Trigger**: Scheduled cron job (agentic-os full refresh and deploy)
**Timestamp**: 2026-05-31 ~20:17 UTC

## Results

| Metric | Value |
|--------|-------|
| Version ID | `564d51e9-64ae-4412-8be5-b37f898c29a1` |
| Memory files (aggregator) | 36 |
| Workspaces | 2 |
| Build time (client) | 10.69s |
| Build time (SSR) | 11.84s |
| Worker startup | 14 ms |
| Modules uploaded | 29 |
| Total upload | 6,032.63 KiB (1,167.81 KiB gzip) |
| Errors | 0 |

## Notes

- Pipeline stable across 5+ consecutive runs with zero errors
- Build time improved slightly to ~10.7s (was ~12.5s) — likely caching effects
- Memory file count stable at 36, 2 workspaces
- Confirmed bun PATH behavior: `bun` not on PATH, must `export PATH="/root/.bun/bin:$PATH"` or prepend full path to every `bun` invocation
- `wrangler` called via `npx wrangler deploy` (works, no separate install needed)
- Aggregate picked up sources from `/root/ulak/memories`, `~/.hermes/memories`, and `/tmp/hermes-memory` (staging dir populated with 20 `.md` files)
- 2,840 modules transformed (client), 2,889 (SSR)
