# Cron Deploy — 2026-05-30

## Summary
Full refresh cron job ran end-to-end successfully. No errors.

## Steps executed
1. Copied `~/.hermes/memories/` → `/tmp/hermes-memory/` (source `/root/ulak/memory/` does not exist — use `~/.hermes/memories/`)
2. Ran `bun run scripts/aggregate.ts` — 22 memory files / 2 workspaces / 14 events
3. `bun run build` — Vite + SSR in ~26s
4. `wrangler deploy` — Version ID `6092c184-5683-41eb-b19f-743860161bff`

## Key env gotchas (still valid)
- `bun` not on PATH: `export PATH="/root/.bun/bin:$PATH"`
- Node v20 too old for wrangler: use `/tmp/node-v22.14.0-linux-x64/bin/` on PATH
  - Full deploy PATH: `export PATH="/tmp/node-v22.14.0-linux-x64/bin:/root/.bun/bin:$PATH"`
- `/root/ulak/memory/` does NOT exist; real source is `~/.hermes/memories/` (plural, with 's')

## Deploy output
- URL: https://tanstack-start-app.lighthousegrouptr.workers.dev
- Version: `6092c184-5683-41eb-b19f-743860161bff`
- Upload: 6022.82 KiB (gzip 1167.29 KiB), 21 files, 54 cached
