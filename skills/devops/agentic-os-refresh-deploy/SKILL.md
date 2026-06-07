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
   - The Agentic OS aggregator expects Hermes memories in `/tmp/hermes-memory/`.
   - Copy files from the Hermes memory source (try multiple locations in order of preference):
     ```bash
     # Try the synced snapshot under /root/ulak/ (both singular and plural)
     for src in /root/ulak/memory /root/ulak/memories; do
       if [ -d "$src" ]; then
         cp -r "$src"/* /tmp/hermes-memory/ 2>/dev/null || true
       fi
     done
     # Overwrite with live memories from ~/.hermes/memories/ if available (ensures latest data)
     cp -r ~/.hermes/memories/* /tmp/hermes-memory/ 2>/dev/null || true
     ```
   - Verify count:
     ```bash
     find /tmp/hermes-memory -type f | wc -l
     ```
   - Note: The synced snapshot (`/root/ulak/memories/`) is updated every 30 minutes and has secrets filtered out (lines containing `api_key`, `password`, etc. are removed). The live memories (`~/.hermes/memories/`) contain the most recent data but may require the Hermes agent to be running and not lock the files. In practice, both work for the aggregator; the live memories are copied last to take precedence.
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
- **Memory source path**: Ensure the Hermes memories are located at `/root/ulak/memories/` (the synced snapshot of `~/.hermes/`). The directory is named `memories` (plural); a common mistake is to use `memory` (singular) which does not exist. If using a different Hermes instance, adjust the source path accordingly.
- **Aggregator scans**: The Agentic OS aggregator script (`scripts/aggregate.ts`) scans multiple Hermes memory locations, including `/tmp/hermes-memory/`, `/root/ulak/memories/`, `/root/.hermes/memories/`, and others. Verify the `HERMES_MEMORIES_DIR` constant in the script includes `/tmp/hermes-memory/` (it should be the last in the array to take precedence). If the aggregator doesn't scan these directories, Hermes memories won't appear in the dashboard.
- **Environment keys**: The aggregator expects `ANTHROPIC_API_KEY` in `.env.local` for full functionality; missing keys will be reported as "needed".
- **Linux platform warning**: The aggregator will warn about skipped macOS-only signals; this does not affect core functionality.
- **Build warnings**: Chunk size warnings (>500 kB) are non‑fatal but indicate opportunities for code‑splitting optimization.
- **Wrangler defaults**: If `workers_dev` or `preview_urls` are not set in `wrangler.jsonc`, they will be enabled by default; override explicitly if desired.

## Verification
- After deployment, verify the version ID matches the output of `wrangler deploy`.
- Check that `src/data/live-data.json` was updated by looking at the aggregator's log line: `[aggregate] wrote /root/code/agentic-os/src/data/live-data.json`.
- Confirm the aggregator scanned Hermes memories by checking its log line for memory file count (should be >0).

## References
- See `references/memory-sync.md` for details on the memory synchronization process and file layout.
- See `references/session-2026-06-07.md`: Session notes from the 2026-06-07 Agentic OS refresh and deploy
- See `references/session-2026-06-07-detailed.md`: Detailed session logs and learnings from the 2026-06-07 Agentic OS refresh and deploy
- See `references/session-2026-06-07-agentic-os-refresh.md`: Session 2026-06-07: Agentic OS Refresh and Deploy

## Session-Specific Learnings (2026-06-07)
- The memory source `/root/ulak/memory/` (singular) does not exist on this system; the correct synced snapshot is at `/root/ulak/memories/` (plural). The skill's fallback loop handles this gracefully by trying multiple locations.
- We successfully copied live memories from `~/.hermes/memories/` to `/tmp/hermes-memory/` to ensure the most recent data was used for aggregation.
- The aggregator correctly processed both `~/.claude/projects` and the synced Hermes memories from `/tmp/hermes-memory/`, reporting 19 memory files across 2 workspaces (note: this count refers to individual memory entries processed by the aggregator, not the raw file count).
- Build warnings about chunk size (>500 kB) are expected for this application and non‑fatal.
- The deployed version ID from this session is: `f3b7fb8e-1ae5-4a92-9f83-5da8b80321bf`.
- The `wrangler deploy` command warns about `workers_dev` and `preview_urls` being enabled by default; these can be overridden explicitly in `wrangler.jsonc` if desired.