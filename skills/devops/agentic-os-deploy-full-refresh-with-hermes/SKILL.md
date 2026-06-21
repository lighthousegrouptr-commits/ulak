---
name: agentic-os-deploy-full-refresh-with-hermes
description: Full refresh and deploy of Agentic OS dashboard with Hermes memory sync
trigger: when needing to refresh and deploy the Agentic OS dashboard with synced Hermes memories
---

# Agentic OS Full Refresh and Deploy with Hermes Memory Sync

## Trigger
When you need to refresh the Agentic OS dashboard data and deploy it, including syncing Hermes agent memories.

## Procedure
1. **Sync Hermes memory files**:
   - Create the sync directory: `mkdir -p /tmp/hermes-memory`
   - Copy memory files from the Hermes agent: `cp -r /root/ulak/memory/. /tmp/hermes-memory/`
   - Verify the sync: `find /tmp/hermes-memory -type f | wc -l` (should match the number of memory files in `/root/ulak/memory/`)

2. **Run the aggregator**:
   - Change to the Agentic OS directory: `cd /root/code/agentic-os`
   - Execute the aggregator script: `bun run scripts/aggregate.ts`
   - This script reads `~/.claude/projects`, `~/.claude/memory`, and `/tmp/hermes-memory/` to generate `src/data/live-data.json`.

3. **Build and deploy**:
   - Build the project: `bun run build`
   - Deploy to Cloudflare Workers: `wrangler deploy`

4. **Report**:
   - Deployed version ID (from wrangler deploy output)
   - Total memory files count (from the sync verification step)
   - Any errors encountered during the process

## Pitfalls
- **Source directory**: The Hermes memories are located in `/root/ulak/memory/` (not `/root/ulak/memories/`). Using the incorrect path will result in zero files synced.
- **Directory permissions**: Ensure the `/tmp/hermes-memory` directory is writable.
- **Aggregator warnings**: On non-macOS platforms, the aggregator will skip macOS-only signals (like Keychain credential count) but will still process project sessions, memory, and Pinecone indexes normally.
- **Build output**: The build process may warn about chunk sizes; these are safe to ignore for deployment.

## Verification
- After deployment, visit the deployed Worker URL to confirm the dashboard loads.
- Check that the memory constellation in the dashboard includes the synced Hermes memories (visible in the Memory graph).

## Related Skills
- `hermes-config-backup`: For backing up Hermes agent configuration.
- `agentic-os-deploy-standard`: For a standard Agentic OS deploy without Hermes memory sync.