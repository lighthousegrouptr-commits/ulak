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
- After making changes to Hermes memories or skills that should reflect in the dashboard.mes memories or skills that should reflect in the dashboard.
- Periodic refresh via cron or manual request.

## Steps

1. **Sync Hermes memory files**
   ```bash
   mkdir -p /tmp/hermes-memory
   cp -r /root/ulak/memories/* /tmp/hermes-memory/
   ```
   Verify files copied: `find /tmp/hermes-memory -type f | wc -l`

2. **Run the aggregator**
   ```bash
   cd /root/code/agentic-os
   bun run scripts/aggregate.ts
   ```
   This scans `~/.claude/projects`, `~/.claude/memory`, and `/tmp/hermes-memory/` and updates `src/data/live-data.json`.

3. **Build the project**
   ```bash
   bun run build
   ```
   Produces optimized client and server assets in `dist/`.

4. **Deploy via Wrangler**
   ```bash
   wrangler deploy
   ```
   Deploys the Worker to Cloudflare. Output includes the Version ID.

1. Sync Hermes memory files from the Hermes server:
   - Note: The Hermes memories may be located at either `/root/ulak/memory/` (singular) or `/root/ulak/memories/` (plural). Check which directory exists.
   - Source: /root/ulak/memories/ (Hermes agent memories on this machine - the synced snapshot from ~/.hermes/)
   - Copy relevant memory files to /tmp/hermes-memory/
   - Example command: `mkdir -p /tmp/hermes-memory && rsync -av /root/ulak/memories/ /tmp/hermes-memory/`

2. Run the aggregator so it picks up both ~/.claude/ AND the synced Hermes memories:
   - Ensure aggregate.ts scans ~/.claude/projects, ~/.claude/memory, AND /tmp/hermes-memory/
   - cd /root/code/agentic-os && bun run scripts/aggregate.ts

3. Build and deploy:
   - Build the application: `cd /root/code/agentic-os && bun run build`
   - Deploy via Wrangler: `cd /root/code/agentic-os && wrangler deploy`
   - Note: wrangler deploy does not accept `--yes` or `-y` flags; it will prompt for confirmation if needed.

## Pitfalls
- If you run `bun run build` directly, you may encounter "Script not found \\\"build\\\"". The build script is defined as `bun run seed:data && vite build`. Using deploy.sh avoids this.
- After building, the output is `dist/server/server.js` but Wrangler expects `index.js`. The deploy.sh copies it for you.
- The deploy.sh also fixes wrangler.json to include routes and assets directory.

## Verification
- Check the deployed version ID from wrangler deploy output.
- Confirm total memory files count from the aggregate step (we found 4 memory files in /tmp/hermes-memory/).
- No errors should appear; if there are warnings about chunk size, they can be ignored for initial deployment.
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
- **Memory source path**: The Hermes memories may be located at either `/root/ulak/memory/` (singular) or `/root/ulak/memories/` (plural). On this system, `/root/ulak/memory/` does not exist, but `/root/ulak/memories/` (the synced snapshot of `~/.hermes/`) does exist. A common mistake is to use the wrong directory name. If using a different Hermes instance, adjust the source path accordingly.
- **Aggregator scans**: The Agentic OS aggregator script (`scripts/aggregate.ts`) scans multiple Hermes memory locations, including `/tmp/hermes-memory/`, `/root/ulak/memories/`, `/root/.hermes/memories/`, and others. Verify the `HERMES_MEMORIES_DIR` constant in the script includes `/tmp/hermes-memory/` (it should be the last in the array to take precedence). If the aggregator doesn't scan these directories, Hermes memories won't appear in the dashboard.
- **Environment keys**: The aggregator expects `ANTHROPIC_API_KEY` in `.env.local` for full functionality; missing keys will be reported as "needed".
- **Linux platform warning**: The aggregator will warn about skipped macOS-only signals; this does not affect core functionality.
- **Build warnings**: Chunk size warnings (>500 kB) are non‑fatal but indicate opportunities for code‑splitting optimization.
- **Wrangler deploy flags**: The `wrangler deploy` command does not accept `--yes` or `-y` flags for automatic confirmation. Using `timeout` with `wrangler deploy` may work, but be aware that it might still prompt for input in some environments.
- **Wrangler defaults**: If `workers_dev` or `preview_urls` are not set in `wrangler.jsonc`, they will be enabled by default; override explicitly if desired.

## Verification
- After deployment, verify the version ID matches the output of `wrangler deploy`.
- Check that `src/data/live-data.json` was updated by looking at the aggregator's log line: `[aggregate] wrote /root/code/agentic-os/src/data/live-data.json`.
- Confirm the aggregator scanned Hermes memories by checking its log line for memory file count (should be >0).

## References
- See `references/cron-job-dependencies.md` for notes on handling missing dependencies in cron job environments.

## References\n- See `references/memory-sync.md` for details on the memory synchronization process and file layout.\n- See `references/session-2026-06-07.md`: Session notes from the 2026-06-07 Agentic OS refresh and deploy\n- See `references/session-2026-06-07-detailed.md`: Detailed session logs and learnings from the 2026-06-07 Agentic OS refresh and deploy\n- See `references/session-2026-06-07-agentic-os-refresh.md`: Session 2026-06-07: Agentic OS Refresh and Deploy
- See `references/session-2026-06-08.md`: Session notes from the 2026-06-08 Agentic OS refresh and deploy
- See `references/session-2026-06-08-detailed.md`: Detailed session logs and learnings from the 2026-06-08 Agentic OS refresh and deploy (this session)

## Session-Specific Learnings (2026-06-07)
- The memory source `/root/ulak/memory/` (singular) does not exist on this system; we used the synced snapshot at `/root/ulak/memories/` (plural) and copied it to `/tmp/hermes-memory/` for the aggregator.
- The aggregator scans multiple Hermes memory locations, including `/tmp/hermes-memory/` (which we populated), `/root/ulak/memories/`, `/root/.hermes/memories/`, and `~/.claude/memory/`, thus capturing both synced snapshot and live memories.
- We copied 5 memory files from `/root/ulak/memories/` to `/tmp/hermes-memory/`.
- The aggregator processed both `~/.claude/projects` and the Hermes memories, reporting 19 memory files across 2 workspaces / 0 Pinecone indexes / 0 vectors / 14 events (plus 2 projects, 1692 assistant msgs from ~/.claude/projects).
- Build warnings about chunk size (>500 kB) are expected for this application and non‑fatal.
- The deployed version ID from this session is: `758c718e-3aa5-4d22-a05a-9669721b9ce2`.
- The `wrangler deploy` command warns about `workers_dev` and `preview_urls` being enabled by default; these can be overridden explicitly in `wrangler.jsonc` if desired.


## Session-Specific Learnings (2026-06-08)
- The memory source `/root/ulak/memory/` (singular) does not exist on this system; we used the synced snapshot at `/root/ulak/memories/` (plural) and copied the memory files (4 files: MEMORY.md, USER.md, MEMORY.md.lock, USER.md.lock) to `/tmp/hermes-memory/` for the aggregator.
- The aggregator scans multiple Hermes memory locations, including `/tmp/hermes-memory/` (which we populated), `/root/ulak/memories/`, `/root/.hermes/memories/`, and `~/.claude/memory/`, thus capturing both synced snapshot and live memories.
- We copied 4 memory files from `/root/ulak/memories/` to `/tmp/hermes-memory/`.
- The aggregator processed both `~/.claude/projects` and the Hermes memories, reporting 18 memory files across 2 workspaces / 0 Pinecone indexes / 0 vectors / 14 events (plus 2 projects, 1693 assistant msgs from ~/.claude/projects).
- Build warnings about chunk size (>500 kB) are expected for this application and non‑fatal.
- The deployed version ID from this session is: `65b246fd-6592-4715-a24f-7694e6fda2cd`.
- The `wrangler deploy` command warns about `workers_dev` and `preview_urls` being enabled by default; these can be overridden explicitly in `wrangler.jsonc` if desired.
- Note: When running as a cron job, the terminal tool may prompt for approval when deleting files in root paths (like `/tmp/hermes-memory/`). To avoid this, we copied only the needed memory files without deleting the directory contents first.
- No errors were encountered during the process.
- Learned that `wrangler deploy` does not accept `--yes` or `-y` flags; the command must be run interactively or with alternative automation approaches.