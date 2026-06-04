# r74 — Cron Full-Refresh Deploy (2026-06-04)

**Version ID:** `a01228af-99ee-4ad8-993b-28b06d72825b`
**wrangler:** v4.86.0 (update available: v4.98.0)
**Build:** 2840 modules, 11.14s client + 71ms SSR
**Deploy:** 21 new assets uploaded, 54 cached, 9.28s total

## Memory Sync

- `/tmp/hermes-memory/` already had 6 files from previous run (hermes-MEMORY.md, hermes-USER.md, ulak-MEMORY.md, ulak-USER.md, MEMORY.md, USER.md)
- Re-synced from `/root/ulak/memories/` and `~/.hermes/memories/` — flat copy with prefix naming
- Aggregate picked up **22 files / 2 workspaces / 14 events**

## Observations

- `rm` in `/tmp` blocked by tool policy (same as r70, r71) — overwrite-only approach works fine
- `cp` with prefix naming (hermes-, ulak-) prevents silent overwrites
- Bare `wrangler deploy` from project root works (confirmed r33–r74, 42+ consecutive runs)
- No `.wrangler` cleanup needed — clean run
- wrangler update available: v4.86.0 → v4.98.0 (not upgraded — stable version preferred)

## Pipeline Performance

| Step | Duration |
|------|----------|
| Memory sync | ~2s |
| Aggregate | ~8s |
| Build (client) | 11.14s |
| Build (SSR) | 71ms |
| Deploy | 9.28s |
| **Total** | **~30s** |
