---
name: agentic-os-full-refresh-deploy-with-hermes-sync
category: devops
description: Full refresh and deploy of Agentic OS dashboard, including syncing Hermes memory files from ~/.hermes/ or /root/ulak/memories/ to /tmp/hermes-memory/ before running the aggregator.
---

# Agentic OS Full Refresh and Deploy with Hermes Memory Sync

## When to Use
Use this skill when you want to refresh the Agentic OS dashboard with the latest data from both ~/.claude/ and Hermes agent memories.

## Steps

1. **Prepare Hermes memory sync directory**
   ```bash
   mkdir -p /tmp/hermes-memory
   ```

2. **Sync Hermes memory files**
   Sync from the live Hermes memories (either ~/.hermes/memories/ or /root/ulak/memories/) to /tmp/hermes-memory/.
   ```bash
   rsync -av /root/ulak/memories/ /tmp/hermes-memory/
   # Alternatively, if using ~/.hermes/:
   # rsync -av ~/.hermes/memories/ /tmp/hermes-memory/
   ```

   **Note:** The sync may create zero-byte `.lock` files; these are ignored by the aggregator and can be safely left.

3. **Run the aggregator**
   From the agentic-os project root, run the TypeScript aggregator script:
   ```bash
   cd /root/code/agentic-os
   bun run scripts/aggregate.ts
   ```
   This scans `~/.claude/projects`, `~/.claude/memory`, and `/tmp/hermes-memory/` (among other sources) and writes `src/data/live-data.json`.

4. **Build the dashboard**
   ```bash
   bun run build
   ```
   This seeds data if needed and builds the Vite + SSR bundle.

5. **Deploy with Wrangler**
   ```bash
   wrangler deploy
   ```
   Deploys the Worker to the configured namespace.

## Pitfalls
- **Lock files**: The Hermes memory directory may contain `.lock` files (zero-byte). They are harmless but can be excluded from sync using `--exclude='*.lock'` if desired.
- **Source directory**: Ensure you are syncing from the correct Hermes memories location. On this system, live memories are at `~/.hermes/memories/` and mirrored at `/root/ulak/memories/`. Either works.
- **Aggregator platform warnings**: On non-macOS platforms, the aggregator will skip macOS-specific signals (Keychain, plan-tier detection). This is expected and does not affect core functionality.
- **Wrangler configuration**: The first deploy may warn about missing `workers_dev` and `preview_urls` settings; these are safe to ignore for personal dashboards.

## Verification
After deployment, visit the deployed URL (shown in the wrangler output) to confirm the dashboard loads and displays updated memory counts and session data.

## Required Tools
- `bun` (Node.js runtime)
- `wrangler` (Cloudflare CLI)
- `rsync` (for syncing memories)

## Related Skills
- `agentic-os-hermes-memory-sync` – focuses only on syncing Hermes memories.
- `agentic-os-refresh-deploy` – refresh and deploy without explicit Hermes memory sync (relies on aggregator's built-in paths).
