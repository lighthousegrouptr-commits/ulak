---
name: agentic-os-deploy
description: Refresh and deploy the Agentic OS dashboard after syncing Hermes memories.
version: 1.1.0
author: Hermes Agent
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [devops, deployment, cloudflare, agentic-os]
    related_skills: [hermes-agent, plan]
---

# Agentic OS Deployment Skill

Standard procedure for refreshing and deploying the Agentic OS dashboard (Cloudflare Worker) after syncing Hermes memory files.

## When to Use
- You have updated Hermes agent memories or skills and want to reflect them in the Agentic OS dashboard.
- You need to rebuild and redeploy the Cloudflare Worker after changes to the agentic-os source.

## Prerequisites
- Access to the Hermes agent memory directory (`~/.hermes/memories/` or `/root/ulak/memories/`).
- The Agentic OS source checked out at `/root/code/agentic-os/`.
- `bun` and `wrangler` installed and configured (wrangler login already performed).
- Hermes sync script has been run recently (or you will run it as part of this skill).

## Steps
1. **Sync Hermes memory files to a temporary location**
   ```bash
   mkdir -p /tmp/hermes-memory
   # First copy synced snapshot (if exists), then overwrite with live memories
   cp -r /root/ulak/memories/* /tmp/hermes-memory/ 2>/dev/null || true
   cp -r ~/.hermes/memories/* /tmp/hermes-memory/ 2>/dev/null || true
   # Note: Live memories copied last to ensure they take precedence over synced snapshots
   ```

2. **Run the aggregator to incorporate both Claude and Hermes memories**
   ```bash
   cd /root/code/agentic-os
   bun run scripts/aggregate.ts
   ```
   - Expect output showing memory files scanned and `live-data.json` written.
   - On non‑macOS platforms, a warning about skipped macOS‑only signals is normal.

3. **Build the production bundle**
   ```bash
   bun run build
   ```
   - This runs `seed:data` (ensuring `live-data.json` exists) then `vite build`.
   - Ignore Vite warnings about `no_bundle`/`rules` in wrangler config; they are irrelevant for the worker build.

4. **Deploy via Wrangler**
   ```bash
   wrangler deploy
   ```
   - The command will read the redirected config from `dist/server/wrangler.json`.
   - Confirm deployment succeeds and note the Version ID from the output.

5. **Verify**
   - The deployed URL is printed (e.g., `https://tanstack-start-app.lighthousegrouptr.workers.dev`).
   - Optionally open the URL to ensure the dashboard loads.

## Pitfalls & Troubleshooting
- **Missing memory source**: If `/root/ulak/memories/` does not exist, the script will still work using `~/.hermes/memories/`; ensure at least one contains the memory files.
- **Aggregator fails due to missing `live-data.json`**: The `build` script runs `seed:data` which copies the example file if needed, so the aggregator should always have a target.
- **Wrangler authentication**: If you see `Unauthorized`, run `wrangler login` first and repeat the deploy step.
- **Build chunk size warnings**: These do not prevent deployment; they are suggestions for optimization.
- **Version ID not recorded**: Capture the `Current Version ID` line from the `wrangler deploy` output for rollback or documentation.

## Verification
- After deployment, visit the provided URL and confirm the dashboard shows updated memory/conversation data (e.g., recent projects, token usage).
- **Understanding the memory count**: The aggregator output line `[aggregate] memory: X files / Y workspaces ...` shows files from `~/.claude/memory/` (Claude Code memories), **not** the Hermes memories we synced. The Hermes memories we copied to `/tmp/hermes-memory/` are used by the aggregator but are not directly counted in this line.
- To verify Hermes memories were processed:
  - Look for `[aggregate] scanning memory fields ...` in the aggregator output - this indicates it's reading from `HERMES_MEMORIES_DIR` (which we set to `/tmp/hermes-memory/`)
  - Check that no errors occurred during memory processing
  - The aggregator combines both sources (`~/.claude/` and `/tmp/hermes-memory/`) when building the final data
- Check that the `value extracted last 7d` metric in the aggregator output matches expectations (e.g., showed `$9.13` in the last run).
- **Memory file count verification**: To count the actual Hermes memory files we synced, run: `find /tmp/hermes-memory -type f | wc -l` (should match the number of files in `/root/ulak/memories/` or `~/.hermes/memories/`).

## Notes
- This skill assumes a Linux host; macOS‑specific signals (Keychain credentials) are intentionally skipped by the aggregator.
- The skill does not modify Hermes agent configuration; it only reads synced memory files.
- For frequent updates, consider adding a cron job that runs this skill automatically.
- See `references/memory-sync-details.md` for detailed information about the memory synchronization process.