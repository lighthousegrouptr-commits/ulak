---
name: agentic-os-full-refresh-deploy
description: Sync Hermes memory files, run the Agentic OS aggregator to include both Claude and Hermes memories, then build and deploy the Agentic OS dashboard.
---
# Agentic OS Full Refresh and Deploy

## Description
Sync Hermes memory files, run the Agentic OS aggregator to include both Claude and Hermes memories, then build and deploy the Agentic OS dashboard.

## Steps

### 1. Prepare Hermes Memory Sync
```bash
# Ensure target directory exists
mkdir -p /tmp/hermes-memory

# Copy Hermes memory files from the Ulak snapshot (source of truth for Hermes memories)
# Note: The Ulak snapshot is at /root/ulak/memory/ (mirror of ~/.hermes/memories/)
cp /root/ulak/memories/* /tmp/hermes-memory/
```

### 2. Run the Aggregator
```bash
cd /root/code/agentic-os
# The aggregator scans:
#   - ~/.claude/projects
#   - ~/.claude/memory
#   - /tmp/hermes-memory/ (the synced Hermes memories)
bun run scripts/aggregate.ts
```

### 3. Build and Deploy
```bash
# Build the application
bun run build

# Deploy to Cloudflare Workers
wrangler deploy
```

## Verification
- After deployment, note the Version ID from the wrangler deploy output.
- The aggregator output will show the total memory files scanned (including Hermes memories).
- Check for any errors in the aggregator, build, or deploy steps.

## Notes
- The Ulak snapshot (`/root/ulak/memories/`) is updated every 30 minutes via cron. For the most recent memories, ensure the sync has run recently.
- The aggregator will skip macOS-specific signals on Linux but still process project sessions, daily totals, and Pinecone indexes.
- If `wrangler deploy` warns about `workers_dev` or `preview_urls`, these can be ignored or explicitly set in `wrangler.jsonc`.

## Pitfalls
- Forgetting to copy the Hermes memory files will result in the aggregator only seeing Claude memories.
- Running the aggregator outside the `/root/code/agentic-os` directory will fail to find the script.
- Deploying without building first will deploy an outdated version.

## Example Output
```
[aggregate] platform: linux — some macOS-only signals (Keychain credential count, exact plan-tier detection)
[aggregate] will be skipped. Project sessions, daily totals, and Pinecone indexes still aggregate normally.
[aggregate] scanning ~/.claude/projects ...
[aggregate] 3 projects, 4412 assistant msgs
[aggregate] memory: 24 files / 3 workspaces / 0 Pinecone indexes / 0 vectors / 8 events
[aggregate] wrote /root/code/agentic-os/src/data/live-data.json
...
✨ Success! Uploaded 21 files (54 already uploaded) (2.89 sec)
...
Deployed tanstack-start-app triggers (3.64 sec)
  https://tanstack-start-app.lighthousegrouptr.workers.dev
Current Version ID: 1c21e4f6-cf83-4130-8bf7-2eda54afd534
```