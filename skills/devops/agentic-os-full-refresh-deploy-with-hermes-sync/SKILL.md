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
      First, clear the sync directory to avoid stale files, then sync from the first available Hermes memories location to /tmp/hermes-memory/.
      We check multiple possible locations in order of preference:
      1. ~/.hermes/memories (live Hermes memories)
      2. /root/ulak/memories (Ulak backup, plural)
      3. ~/.hermes/memory (live Hermes memories, singular - fallback)
      4. /root/ulak/memory (Ulak backup, singular - fallback)
      Using rsync with --delete ensures an exact mirror; if rsync is not available, we clear the directory and copy.
      ```bash
      # Ensure sync directory exists and is empty
      rm -rf /tmp/hermes-memory
      mkdir -p /tmp/hermes-memory
      # Define an array of possible source directories
      memdirs=(
        "$HOME/.hermes/memories"
        "/root/ulak/memories"
        "$HOME/.hermes/memory"
        "/root/ulak/memory"
      )
      # Find the first existing directory
      src_dir=""
      for dir in "${memdirs[@]}"; do
        if [ -d "$dir" ]; then
          src_dir="$dir"
          break
        fi
      done
      if [ -z "$src_dir" ]; then
        echo "Error: No Hermes memories directory found in: ${memdirs[*]}" >&2
        exit 1
      fi
      # Prefer rsync if available, otherwise use cp
      if command -v rsync >/dev/null 2>&1; then
        rsync -av --exclude='*.lock' --delete "$src_dir/" /tmp/hermes-memory/
      else
        # rsync not available: copy
        cp -r "$src_dir"/. /tmp/hermes-memory/
      fi
      # Remove any lock files that may have been copied
      find /tmp/hermes-memory -name '*.lock' -delete
      # This ensures lock files are not counted as memory files.
      ```

  3. **Verify sync count (optional)**
      ```bash
      echo "Synced $(find /tmp/hermes-memory -type f -not -name '*.lock' | wc -l) memory files (excluding .lock)."
      ```

  4. **Run the aggregator**\n      From the agentic-os project root, run the TypeScript aggregator script:\n      ```bash\n      cd /root/code/agentic-os\n      bun run scripts/aggregate.ts\n      ```\n      This scans `~/.claude/projects`, `~/.claude/memory`, and `/tmp/hermes-memory/` (among other sources) and writes `src/data/live-data.json`.\n\n  5. **Update agentic-os source (optional)**\n      To ensure you are building the latest version, you can pull any upstream changes:\n      ```bash\n      cd /root/code/agentic-os\n      git pull origin main\n      ```\n      (If you are on a different branch or prefer not to auto-merge, skip this step.)\n\n  6. **Build the dashboard**\n      ```bash
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
## Verification
After deployment, visit the deployed URL (shown in the wrangler output) to confirm the dashboard loads and displays updated memory counts and session data.
   The aggregator output (if available) will show the memory file count, which should match the number of non-lock files in /tmp/hermes-memory/.

## Troubleshooting

- **`bun: command not found`**  
  Install bun via `curl -fsSL https://bun.sh/install | bash` and restart the shell, or ensure `~/.bun/bin` is in your PATH.

- **`wrangler: command not found`**  
  Install wrangler globally: `npm install -g wrangler` (requires Node.js).

- **Aggregator fails with "Cannot find module"**  
  Run `bun install` inside `/root/code/agentic-os` to install dependencies.

- **Build fails due to missing modules**  
  Ensure you have run `bun install` after pulling updates.

- **Wrangler deployment warnings about `workers_dev` and `preview_urls`**  
  These are safe to ignore for personal dashboards; you can explicitly set them in `wrangler.jsonc` if desired.

## Required Tools
- `bun` (Node.js runtime)
- `wrangler` (Cloudflare CLI)
- `rsync` (for syncing memories)

## Related Skills
- `agentic-os-hermes-memory-sync` – focuses only on syncing Hermes memories.
- `agentic-os-refresh-deploy` – refresh and deploy without explicit Hermes memory sync (relies on aggregator's built-in paths).
