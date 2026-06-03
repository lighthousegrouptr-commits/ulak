# Agentic OS Full Refresh Deploy — r60

**Date:** 2026-06-03
**Type:** Cron (autonomous)
**Version ID:** `e3395e24-81b4-4205-b815-3526d58671fc`
**Wrangler:** v4.90.0

## Pipeline

1. **Memory sync** — Synced from `~/.hermes/memories/` and `/root/ulak/memories/` → `/tmp/hermes-memory/` using subdirectory + prefixed copy pattern
2. **Aggregator** — 2 projects, 1458 assistant msgs, 26 memory files / 4 workspaces / 14 events
3. **Build** — Vite client+SSR: ~2840 modules, 12.95s. Worker: 15,822 bytes
4. **Deploy** — 21 new/modified assets uploaded, 54 cached. Total upload: 15.57 KiB / gzip: 4.27 KiB

## Memory files synced

| File | Source |
|------|--------|
| `MEMORY.md` | `~/.hermes/memories/` (flat copy) |
| `USER.md` | `~/.hermes/memories/` (flat copy) |
| `hermes-MEMORY.md` | `~/.hermes/memories/` (prefixed) |
| `hermes-USER.md` | `~/.hermes/memories/` (prefixed) |
| `ulak-MEMORY.md` | `/root/ulak/memories/` (prefixed) |
| `ulak-USER.md` | `/root/ulak/memories/` (prefixed) |
| `hermes/MEMORY.md`, `hermes/USER.md` | subdirectory copies |
| `ulak/MEMORY.md`, `ulak/USER.md` | subdirectory copies |

## Errors

None. Clean deploy.

## Key verification

- `dist/server/wrangler.json` propagated correctly (Vite redirect pattern)
- KV binding `LIVE_DATA` (df2bda58d7bb4abe91569c4c48c5bf5b) present
- Route: `agentic.lighthousegroup.net.tr/*` (zone: lighthousegroup.net.tr)
- Platform: Linux (macOS-only signals skipped as expected)
