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

## Steps\n1. **Sync Hermes memory files to a temporary location**\n   ```bash\n   mkdir -p /tmp/hermes-memory\n   # Try both possible directory names under /root/ulak/ (memory and memories)\n   for src in /root/ulak/memory /root/ulak/memories; do\n     if [ -d \"$src\" ]; then\n       cp -r \"$src\"/* /tmp/hermes-memory/ 2>/dev/null || true\n     fi\n   done\n   # Then overwrite with live memories from ~/.hermes/memories/ (if exists)\n   cp -r ~/.hermes/memories/* /tmp/hermes-memory/ 2>/dev/null || true\n   # Note: Live memories copied last to ensure they take precedence over synced snapshots\n   ```\n\n2. **Run the aggregator to incorporate both Claude and Hermes memories**\n   ```bash\n   cd /root/code/agentic-os\n   bun run scripts/aggregate.ts\n   ```\n   - Expect output showing memory files scanned and `live-data.json` written.\n   - On non‑macOS platforms, a warning about skipped macOS‑only signals is normal.\n\n3. **Build the production bundle**\n   ```bash\n   bun run build\n   ```\n   - This runs `seed:data` (ensuring `live-data.json` exists) then `vite build`.\n   - Ignore Vite warnings about `no_bundle`/`rules` in wrangler config; they are irrelevant for the worker build.\n\n4. **Deploy via Wrangler**\n   ```bash\n   wrangler deploy\n   ```\n   - The command will read the redirected config from `dist/server/wrangler.json`.\n   - Confirm deployment succeeds and note the Version ID from the output.\n\n5. **Verify**\n   - The deployed URL is printed (e.g., `https://tanstack-start-app.lighthousegrouptr.workers.dev`).\n   - Optionally open the URL to ensure the dashboard loads.\n\n## Pitfalls & Troubleshooting\n- **Missing memory source**: If neither `/root/ulak/memory/` nor `/root/ulak/memories/` exist, the script will still work using `~/.hermes/memories/`; ensure at least one contains the memory files.\n- **Aggregator fails due to missing `live-data.json`**: The `build` script runs `seed:data` which copies the example file if needed, so the aggregator should always have a target.\n- **Wrangler authentication**: If you see `Unauthorized`, run `wrangler login` first and repeat the deploy step.\n- **Build chunk size warnings**: These do not prevent deployment; they are suggestions for optimization.\n- **Version ID not recorded**: Capture the `Current Version ID` line from the `wrangler deploy` output for rollback or documentation.\n\n## Verification\n- After deployment, visit the provided URL and confirm the dashboard shows updated memory/conversation data (e.g., recent projects, token usage).\n- **Understanding the memory count**: The aggregator output line `[aggregate] memory: X files / Y workspaces ...` shows files from `~/.claude/memory/` (Claude Code memories), **not** the Hermes memories we synced. The Hermes memories we copied to `/tmp/hermes-memory/` are used by the aggregator but are not directly counted in this line.\n- To verify Hermes memories were processed:\n  - Look for `[aggregate] scanning memory fields ...` in the aggregator output - this indicates it's reading from `HERMES_MEMORIES_DIR` (which we set to `/tmp/hermes-memory/`)\n  - Check that no errors occurred during memory processing\n  - The aggregator combines both sources (`~/.claude/` and `/tmp/hermes-memory/`) when building the final data\n- Check that the `value extracted last 7d` metric in the aggregator output matches expectations (e.g., showed `$9.13` in the last run).\n- **Memory file count verification**: To count the actual Hermes memory files we synced, run: `find /tmp/hermes-memory -type f | wc -l` (should match the number of files in `/root/ulak/memory/` or `/root/ulak/memories/` or `~/.hermes/memories/`).\n\n## Notes\n- This skill assumes a Linux host; macOS‑specific signals (Keychain credentials) are intentionally skipped by the aggregator.\n- The skill does not modify Hermes agent configuration; it only reads synced memory files.\n- For frequent updates, consider adding a cron job that runs this skill automatically.\n- See `references/memory-sync-details.md` for detailed information about the memory synchronization process.