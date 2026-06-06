---
name: agentic-os-refresh-deploy
description: Refresh the Agentic OS dashboard by syncing Hermes memories, running the aggregator, building, and deploying via Wrangler.
category: devops
version: 1.0
---

# Agentic OS Refresh and Deploy

Refresh the Agentic OS dashboard by syncing Hermes memories, running the aggregator, building, and deploying via Wrangler.

## Trigger Conditions
- You need to update the Agentic OS dashboard with the latest Hermes agent memories.
- After making changes to Hermes memories or skills that should reflect in the dashboard.
- Periodic refresh via cron or manual request.

## Steps
1. **Prepare memory sync directory**
   ```bash
   mkdir -p /tmp/hermes-memory
   ```
2. **Sync Hermes memory files**
   - Source: `/root/ulak/memories/` (contains `MEMORY.md`, `USER.md`, etc.)
   - Copy all files to the sync directory:
   ```bash
   cp -r /root/ulak/memories/* /tmp/hermes-memory/
   ```
   - Verify count: `find /tmp/hermes-memory -type f | wc -l`
3. **Run the aggregator**
   - Change to the Agentic OS project:
   ```bash
   cd /root/code/agentic-os
   ```
   - Execute the aggregation script:
   ```bash
   bun run scripts/aggregate.ts
   ```
   - This reads `~/.claude/` and `/tmp/hermes-memory/` and writes `src/data/live-data.json`.
   - Note: On Linux, macOS-only signals (Keychain credentials, exact plan-tier) are skipped; this is expected.
4. **Build the production bundle**
   ```bash
   bun run build
   ```
   - This runs `seed:data` and `vite build`, producing optimized client and server assets.
5. **Deploy via Wrangler**
   ```bash
   wrangler deploy
   ```
   - The command outputs the deployed version ID, upload statistics, and any warnings.
   - Capture the version ID from the line: `Current Version ID: <uuid>`.
6. **Report**
   - Deployed version ID (from wrangler deploy output)
   - Total memory files count (from step 2)
   - Any errors encountered during the process

## Pitfalls
- **Memory source path**: Ensure the Hermes memories are located at `/root/ulak/memories/` (the synced snapshot of `~/.hermes/`). If using a different Hermes instance, adjust the source path accordingly.
- **Environment keys**: The aggregator expects `ANTHROPIC_API_KEY` in `.env.local` for full functionality; missing keys will be reported as "needed".
- **Linux platform warning**: The aggregator will warn about skipped macOS-only signals; this does not affect core functionality.
- **Build warnings**: Chunk size warnings (>500 kB) are non‑fatal but indicate opportunities for code‑splitting optimization.
- **Wrangler defaults**: If `workers_dev` or `preview_urls` are not set in `wrangler.jsonc`, they will be enabled by default; override explicitly if desired.

## Verification
- After deployment, verify the version ID matches the output of `wrangler deploy`.
- Check that `src/data/live-data.json` was updated by looking at the aggregator's log line: `[aggregate] wrote /root/code/agentic-os/src/data/live-data.json`.
- Confirm memory file count matches the number of files copied from `/root/ulak/memories/`.

## References
- See `references/memory-sync.md` for details on the memory synchronization process and file layout.