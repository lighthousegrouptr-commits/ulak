# Agentic OS Deployment Checklist

## Pre-deployment
- [ ] Ensure `/tmp/hermes-memory` exists: `mkdir -p /tmp/hermes-memory`
- [ ] Sync Hermes memories: `cp -r /root/ulak/memories/* /tmp/hermes-memory/`
- [ ] Verify sync count: `find /tmp/hermes-memory -type f | wc -l` (should match source)
- [ ] Change to Agentic OS dir: `cd /root/code/agentic-os`

## Aggregator
- [ ] Run aggregator: `bun run scripts/aggregate.ts`
- [ ] Watch for warnings (macOS-only signals skipped on Linux)
- [ ] Confirm `src/data/live-data.json` updated

## Build & Deploy
- [ ] Build: `bun run build`
- [ ] Deploy: `wrangler deploy`
- [ ] Capture version ID from output
- [ ] Verify deployment URL loads

## Post-deployment
- [ ] Check memory files count in dashboard matches synced count
- [ ] Ensure no errors in logs