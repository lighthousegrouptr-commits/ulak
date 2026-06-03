# 2026-06-03 Cron Full-Refresh Deploy — r63

**Date:** 2026-06-03
**Trigger:** Scheduled cron job — Agentic OS full refresh and deploy

## Steps executed

1. **Sync Hermes memories → /tmp/hermes-memory/**
   - Source: `/root/ulak/memories/` (2 files: MEMORY.md, USER.md)
   - Also synced Hermes server memories (8 files total including subdirs hermes/, ulak/)
   - Used subdirectory-based copy to avoid name collisions

2. **Run aggregator**
   - `cd /root/code/agentic-os && bun run scripts/aggregate.ts`
   - Result: 26 memory files / 4 workspaces / 14 events
   - 2 Claude projects, 1458 assistant msgs
   - 8 skills installed, 5 used in logs, 0 runs in last 7d

3. **Build**
   - `bun run build` — 2840 modules, ~11s
   - Produced `dist/client/` + `dist/server/`

4. **Deploy**
   - First attempt: FAILED — `ENOENT` on stale asset hash `workspaces._id-BE4tv3uI.js`
   - Fix: re-ran `bun run build` (fresh hashes), then `wrangler deploy`
   - Second attempt: SUCCESS

## Result

| Field | Value |
|-------|-------|
| Version ID | `97ccf4d0-1fd8-481a-8e66-8123c0b501f2` |
| Memory files | 26 (4 workspaces) |
| Build time | ~11s |
| Assets uploaded | 75 (all new/modified) |
| Errors | 1 (stale asset hash, resolved by rebuild) |

## Lessons

- **Stale asset hash race**: If `wrangler deploy` fails with `ENOENT` on a JS asset, immediately rebuild. The build output hashes changed between the first build and deploy calls.
- **`rm -rf .wrangler` not always needed**: The second deploy succeeded without it. Only needed when `.wrangler/` exists from a previous failed run.
- **Bare `wrangler deploy` works**: No need for `npx` prefix — `wrangler` is on PATH.
