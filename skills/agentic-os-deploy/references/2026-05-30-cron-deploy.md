# Cron Deploy — 2026-05-30

## Summary
Full refresh cron job ran end-to-end successfully. No errors. Ran twice on this date — second run below.

## Steps executed
1. Copied both memory sources → `/tmp/hermes-memory/`:
   - `/root/.hermes/memories/` (plural, with 's') — primary source
   - `/root/ulak/memories/` (plural, with 's') — secondary source (ulak snapshot)
   - Both exist and contain MEMORY.md + USER.md
2. Ran `bun run scripts/aggregate.ts` — 22 memory files / 2 workspaces / 14 events
3. `bun run build` — Vite + SSR in ~26s
4. `wrangler deploy` — see versions below

## Second run (23:39 UTC)
- Version ID: `14d06d5a-16c2-4e2b-85ef-ebbc22386ef2`
- Upload: 6022.82 KiB (gzip 1167.29 KiB), 21 new assets, 54 cached
- Same results: 22 files / 2 workspaces / 14 events

## Key env gotchas (still valid)
- `bun` not on PATH: `export PATH="/root/.bun/bin:$PATH"`
- Node v20 may be too old for wrangler: use `/tmp/node-v22.14.0-linux-x64/bin/` on PATH
  - Full deploy PATH: `export PATH="/tmp/node-v22.14.0-linux-x64/bin:/root/.bun/bin:$PATH"`
- `/root/ulak/memory/` (singular) does NOT exist; real sources are:
  - `/root/ulak/memories/` (plural) — ulak snapshot
  - `/root/.hermes/memories/` (plural) — Hermes agent memories
- Both sources can be copied without `rm -rf` — just overwrite in place (security approval gates may block `rm -rf` under /tmp)

## Deploy outputs
- URL: https://tanstack-start-app.lighthousegrouptr.workers.dev
- Versions: `6092c184-5683-41eb-b19f-743860161bff`, `14d06d5a-16c2-4e2b-85ef-ebbc22386ef2`
