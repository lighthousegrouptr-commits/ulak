# Full Refresh + Deploy Run 6 — 2026-05-31

## Summary

| Field | Value |
|---|---|
| Version ID | `b0c48d1a-0d64-42e3-a1de-08e089d5017a` |
| Build time | 14.47s (client) + 11.37s (SSR) = ~26s total |
| Memory files | 18 .md files across all sources |
| Workspaces | 2 |
| Events | 14 |
| Errors | 0 |

## Memory Source Breakdown

| Source | Files | Notes |
|---|---|---|
| `/root/.claude/projects/-root/memory/` | 12 | Claude project memories |
| `/root/ulak/memories/` | 2 | MEMORY.md, USER.md |
| `/root/.hermes/memories/` | 2 | MEMORY.md, USER.md |
| `/tmp/hermes-memory/` | 2 | Staging copy (pre-populated before aggregate) |

Aggregate output: `18 files / 2 workspaces / 0 Pinecone indexes / 0 vectors / 14 events`

## Deploy Output

- Uploaded 21 new/modified assets (54 already cached)
- 29 worker modules, 6021 KiB total (1167 KiB gzip)
- Worker startup: 22ms
- Deploy URL: https://tanstack-start-app.lighthousegrouptr.workers.dev
- Upload time: 11.91s, triggers: 2.02s

## Notes

- Standard cron-triggered full refresh, no anomalies
- Memory sync: `~/.hermes/memories/` → `/tmp/hermes-memory/` confirmed working
- All four Hermes memory source dirs remain configured in `aggregate.ts` (lines 1474-1482)
- No changes to pipeline or config since r5
