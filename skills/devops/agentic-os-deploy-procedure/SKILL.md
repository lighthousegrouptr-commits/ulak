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
   - Source: /root/ulak/memory/ (Hermes agent memories on this machine)
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
- None encountered in this session.

## Notes
- This session deployed version: da5fec74-5f3c-44d8-88e7-f0a4a56afd3f
- Total Hermes memory files synced: 2 (from /root/ulak/memories/ to /tmp/hermes-memory/)
- The aggregator reported 20 total memory files across all sources.