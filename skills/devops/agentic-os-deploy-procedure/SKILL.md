---
name: agentic-os-deploy-procedure
description: Refresh and deploy the Agentic OS dashboard by syncing Hermes memories, running the aggregator, building, and deploying via Wrangler.
category: devops
version: 1.0
---
# Agentic OS Deployment Procedure

## Trigger
Run this procedure when you need to refresh the Agentic OS dashboard with the latest Hermes memories and deploy the updated version.

## Steps

1. Sync Hermes memory files from the Hermes server:
   - Source: /root/ulak/memories/ (Hermes agent memories on this machine)
   - Copy relevant memory files to /tmp/hermes-memory/
   ```
   mkdir -p /tmp/hermes-memory
   cp -r /root/ulak/memories/* /tmp/hermes-memory/
   ```

2. Run the aggregator so it picks up both ~/.claude/ AND the synced Hermes memories:
   - Ensure aggregate.ts scans ~/.claude/projects, ~/.claude/memory, AND /tmp/hermes-memory/
   - cd /root/code/agentic-os && bun run scripts/aggregate.ts

3. Build and deploy:
   - bun run build
   - wrangler deploy

## Verification
- Check the output for the deployed version ID.
- Confirm the total memory files count from the aggregator output.
- No errors should appear in the build or deploy steps.

## Pitfalls
- Ensure the source directory /root/ulak/memories exists; if empty, verify the Ulak sync cron job has run recently (hermes cron list).

## Notes
- This session deployed version: c0edb0f4-8daf-4e6a-b9e3-66691ac7d844
- Total Hermes memory files synced: 4 (from /root/ulak/memories/ to /tmp/hermes-memory/)
- Tip: Ensure you are in the Agentic OS project root (`/root/code/agentic-os/`) before running `bun run build` to avoid 'Script not found \\\\\\\"build\\\\\\\"' errors.
- The aggregator reported 21 files / 2 workspaces / 0 Pinecone indexes / 0 vectors / 8 events.