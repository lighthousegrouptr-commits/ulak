# Full Refresh + Deploy Run 8 — 2026-06-01

## Summary

| Field | Value |
|---|---|
| Version ID | `274b1973-8efb-44e5-b8fc-b0e79cbb7adc` |
| Build time | 10.68s (client) + 11.40s (SSR) = ~22s total |
| Memory files | 18 .md files across all sources |
| Workspaces | 2 |
| Events | 14 |
| Errors | 0 |

## Memory Source Breakdown

| Source | Files | Notes |
|---|---|---|
| `/root/.claude/projects/-root/memory/` | ~12 | Claude project memories |
| `/root/ulak/memories/` | 2 | MEMORY.md, USER.md |
| `/root/.hermes/memories/` | 2 | MEMORY.md, USER.md |
| `/tmp/hermes-memory/` | 2 | Staging copy (pre-populated before aggregate) |

Aggregate output: `18 files / 2 workspaces / 0 Pinecone indexes / 0 vectors / 14 events`

## Deploy Output

- Uploaded 21 new/modified assets (54 already cached)
- 29 worker modules, 6021 KiB total (1167 KiB gzip)
- Worker startup: 15ms
- Deploy URL: https://tanstack-start-app.lighthousegrouptr.workers.dev
- Upload time: 12.28s, triggers: 1.85s

## Notes

- Standard cron-triggered full refresh, no anomalies
- `bun` not on `$PATH` in cron environment — `export PATH="/root/.bun/bin:$PATH"` required
- `~/.claude/memory/` (singular) does NOT exist on this machine — only `~/.claude/projects/` with per-project `memory/` subdirs contributes Claude-side data
- All four Hermes memory source dirs remain configured in `aggregate.ts` (lines 1474-1482)
- No changes to pipeline or config since r7
