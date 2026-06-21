---
name: agentic-os-full-refresh-deploy-with-hermes-sync
category: devops
description: Full refresh and deploy of Agentic OS dashboard, including syncing Hermes memory files from ~/.hermes/memories/ or /root/ulak/memories/ to /tmp/hermes-memory/ before running the aggregator.
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
      Sync from the live Hermes memories (~/.hermes/memories/) to /tmp/hermes-memory/.
      If the live memories are not available, fall back to the Ulak backup (/root/ulak/memories/).
      ```bash
      # Prefer rsync if available, otherwise use cp
      if command -v rsync >/dev/null 2>&1; then
        if [ -d ~/.hermes/memories ]; then
          rsync -av --exclude='*.lock' ~/.hermes/memories/ /tmp/hermes-memory/
        else
          rsync -av --exclude='*.lock' /root/ulak/memories/ /tmp/hermes-memory/
        fi
      else
        if [ -d ~/.hermes/memories ]; then
          mkdir -p /tmp/hermes-memory && cp -r ~/.hermes/memories/. /tmp/hermes-memory/
        else
          mkdir -p /tmp/hermes-memory && cp -r /root/ulak/memories/. /tmp/hermes-memory/
        fi
      fi
      # Remove any lock files that may have been copied
      find /tmp/hermes-memory -name '*.lock' -delete
      ```

  3. **Verify sync count (optional)**
      ```bash
      echo "Synced $(find /tmp/hermes-memory -type f | wc -l) memory files (excluding .lock)."
      ```

  4. **Run the aggregator**
      From the agentic-os project root, run the TypeScript aggregator script:
      ```bash
      cd /root/code/agentic-os
      bun run scripts/aggregate.ts
      ```
      This scans `~/.claude/projects`, `~/.claude/memory`, and `/tmp/hermes-memory/` (among other sources) and writes `src/data/live-data.json`.

  5. **Build the dashboard**
      ```bash
      bun run build
      ```
      This seeds data if needed and builds the Vite + SSR bundle.

  6. **Deploy with Wrangler**
      ```bash
      wrangler deploy
      ```

      **Note:** The first deploy may warn about missing `workers_dev` and `preview_urls` settings; these are safe to ignore for personal dashboards.

## Related Skills
- **Source directory**: Ensure you are syncing from the correct Hermes memories location. On this system, live memories are at `~/.hermes/memories/` and mirrored at `/root/ulak/memories/`. Either works.
- **Aggregator platform warnings**: On non-macOS platforms, the aggregator will skip macOS-specific signals (Keychain, plan-tier detection). This is expected and does not affect core functionality.
- **Wrangler configuration**: The first deploy may warn about missing `workers_dev` and `preview_urls` settings; these are safe to ignore for personal dashboards.\n- See `references/memory-sync-verification.md` for verification details.\n\n## Verification\nAfter deployment, visit the deployed URL (shown in the wrangler output) to confirm the dashboard loads and displays updated memory counts and session data.
   The aggregator output (if available) will show the memory file count, which should match the number of non-lock files in /tmp/hermes-memory/.

## Required Tools
- `bun` (Node.js runtime)
- `wrangler` (Cloudflare CLI)
- `rsync` (for syncing memories)

## Related Skills
- `agentic-os-hermes-memory-sync` – focuses only on syncing Hermes memories.
- `agentic-os-refresh-deploy` – refresh and deploy without explicit Hermes memory sync (relies on aggregator's built-in paths).
