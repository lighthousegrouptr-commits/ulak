# 2026-05-31 Full Refresh & Deploy

## What was done
Scheduled cron job: full Agentic OS refresh — sync Hermes memories, aggregate, build, deploy.

## Environment
- Platform: Linux (VPS), not macOS — aggregate warns about macOS-only signals but works fine
- Node: v20 (system), wrangler v4.86.0 works on it
- bun: `/root/.bun/bin/bun` (not on default PATH)

## Pipeline results

### Memory sync
```bash
mkdir -p /tmp/hermes-memory
cp /root/ulak/memories/MEMORY.md /tmp/hermes-memory/ulak-MEMORY.md
cp /root/ulak/memories/USER.md /tmp/hermes-memory/ulak-USER.md
cp /root/.hermes/memories/MEMORY.md /tmp/hermes-memory/hermes-MEMORY.md
cp /root/.hermes/memories/USER.md /tmp/hermes-memory/hermes-USER.md
```
4 files synced — no `rm -rf` needed (would have been blocked).

### Aggregator
```
[aggregate] memory: 22 files / 2 workspaces / 0 Pinecone indexes / 0 vectors / 14 events
[aggregate] 2 projects, 1458 assistant msgs
[aggregate] skills: 9 installed · 5 used in logs · 6 runs in last 7d
```
Aggregator confirmed all Hermes/Ulak source paths are working correctly.

### Build
- Client build: 12.04s (2840 modules)
- SSR build: 12.95s (2889 modules)
- No errors

### Deploy
```
Current Version ID: 1230c445-a8f7-49ee-bbfa-22f04848b875
URL: https://tanstack-start-app.lighthousegrouptr.workers.dev
Total Upload: 6022.83 KiB / gzip: 1167.27 KiB
```

## Confirmed working
- All 4 Hermes memory source paths in `aggregate.ts` are correct
- Prefixed filenames (`ulak-*`, `hermes-*`) prevent duplicate nodes
- `bun not on PATH` workaround: export PATH or use full path
- `rm -rf` under `/tmp` is blocked by approval gate — skip it entirely
- wrangler v4.86.0 works on Node 20 (no version error)

## No errors
Full pipeline completed without errors on first attempt.
