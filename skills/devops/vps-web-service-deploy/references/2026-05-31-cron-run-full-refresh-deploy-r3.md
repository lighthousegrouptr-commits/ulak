# 2026-05-31 — Full Refresh + Deploy Run 3

**Trigger**: Scheduled cron job (agentic-os full refresh and deploy)
**Timestamp**: 2026-05-31 ~19:40 UTC

## Results

| Metric | Value |
|--------|-------|
| Version ID | `247b9cd0-ffae-4503-9d5f-b0622cd027ac` |
| Memory files (aggregator) | 36 |
| Workspaces | 2 |
| Build time (client) | 12.60s |
| Build time (SSR) | 12.14s |
| Worker startup | 13 ms |
| Modules uploaded | 29 |
| Total upload | 6,032.63 KiB (1,167.81 KiB gzip) |
| Errors | 0 |

## Notes

- Pipeline stable across 4+ consecutive runs with zero errors
- Build time consistent at ~12.5s
- Memory file count stable at 36
- Confirmed: `/root/ulak/memory/` (singular) does NOT exist — correct path is `/root/ulak/memories/` (plural)
- `/root/.hermes/memory/` (singular) also does NOT exist — correct path is `/root/.hermes/memories/` (plural)
- `bun` not on PATH — must use `/root/.bun/bin/bun` or export PATH
- `wrangler` available directly at `/usr/bin/wrangler`
- Aggregate already scans all Hermes memory paths directly (lines 1474-1482 of aggregate.ts) — the `/tmp/hermes-memory/` staging is supplementary
