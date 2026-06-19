---
name: agentic-os-refresh-and-deploy
description: Perform a full refresh of the Agentic OS dashboard by syncing Hermes memory files, running the aggregator, building, and deploying via Wrangler.
trigger: manual
---

## Description
Perform a full refresh of the Agentic OS dashboard by syncing Hermes memory files, running the aggregator, building, and deploying via Wrangler.

## Steps

1. **Sync Hermes memory files**
   - Source: `/root/ulak/memories/` (contains MEMORY.md and USER.md synced from the live Hermes agent)
   - Destination: `/tmp/hermes-memory/`
   - Ensure the directory exists and copy the files:
     ```bash
     mkdir -p /tmp/hermes-memory && cp /root/ulak/memories/* /tmp/hermes-memory/
     ```

2. **Run the aggregator**
   - Change to the Agentic OS directory:
     ```bash
     cd /root/code/agentic-os
     ```
   - Execute the aggregation script (this scans `~/.claude/projects`, `~/.claude/memory`, and `/tmp/hermes-memory/`):
     ```bash
     bun run scripts/aggregate.ts
     ```
   - The aggregator writes `src/data/live-data.json`.

3. **Build the application**
   ```bash
   bun run build
   ```
   - This runs `seed:data` and `vite build`, producing optimized assets in `dist/`.

4. **Deploy via Wrangler**
   ```bash
   wrangler deploy
   ```
   - The worker is deployed to the configured Workers subdomain.

## Verification
- After deployment, note the Version ID from the Wrangler output.
- The aggregator output includes the total memory files count (e.g., "memory: 24 files / 3 workspaces").
- Check for any error messages in the output of each step.

## Pitfalls
- **Memory source path**: The Hermes memory files are located at `/root/ulak/memories/` (not `/root/ulak/memory/`). Using the wrong path will result in "No such file or directory".
- **Aggregator platform warning**: On Linux, the aggregator will warn about skipped macOS-only signals (Keychain credential count, exact plan-tier detection). This is expected and does not affect the core functionality.
- **Wrangler configuration warnings**: If `workers_dev` or `preview_urls` are not explicitly set in `wrangler.jsonc`, Wrangler will enable them by default. To override, set them explicitly in the configuration file.

## Required Tools
- Bun package manager
- Wrangler CLI
- Access to the Hermes memory files and Agentic OS source code

## Related Skills
- `hermes-config-backup` (for backing up Hermes configuration)
- `agentic-os-hermes-memory-sync` (for syncing memories only)