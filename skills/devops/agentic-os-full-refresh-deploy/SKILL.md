---
name: agentic-os-full-refresh-deploy
description: Sync Hermes memory files, run the Agentic OS aggregator, build, and deploy the dashboard.
category: devops
---

# Agentic OS Full Refresh and Deploy

Sync Hermes memory files, run the aggregator, build, and deploy the Agentic OS dashboard.

## When to Use
- After updating Hermes memories or Claude Code data.
- Periodically to keep the dashboard in sync.
- When deploying changes to the Agentic OS dashboard.

## Steps
 
1. **Sync Hermes memory files**  
   ```bash 
   mkdir -p /tmp/hermes-memory 
# Prefer live Hermes memories; fallback to ulak memories directory if needed 
if [ -d "/root/.hermes/memories" ]; then 
  cp -av /root/.hermes/memories/* /tmp/hermes-memory/ 
elif [ -d "/root/ulak/memories" ]; then 
  cp -av /root/ulak/memories/* /tmp/hermes-memory/ 
else 
  echo "No Hermes memory source found" >&2 
  exit 1 
fi
   ``` 

2. **Count synced memory files (optional verification)**  
   ```bash 
   find /tmp/hermes-memory -type f | wc -l 
   ``` 

3. **Run the aggregator**
   ```bash
   cd /root/code/agentic-os
   bun run scripts/aggregate.ts
    - Note: If /root/ulak/memory does not exist, use /root/ulak/memories instead (as seen in Ulak repo).
   ```
   - This reads `~/.claude/projects`, `~/.claude/memory`, and `/tmp/hermes-memory/`.
   - Outputs `src/data/live-data.json`.

4. **Build the dashboard**\n   ```bash\n   # First ensure live-data.json exists (copies example if needed)\n   bun run seed:data\n   # Then build the production assets\n   bun run vite build\n   ```\n   - Produces production assets in `dist/`.\n   - The build command is `vite build` accessed via `bun run vite build` (no direct \"build\" script in package.json).

5. **Deploy via Wrangler**\n   ```bash\n   # Remove any conflicting wrangler deploy config if present\n   rm -f ~/.wrangler/deploy/config.json\n   # Deploy using the built worker and specific wrangler config\n   wrangler deploy dist/server/index.js --config dist/server/wrangler.json\n   ```\n   - Deploys the Cloudflare Worker.\n   - Outputs the deployed version ID.

## Verification
- After deployment, check the version ID in the wrangler output.
- Ensure the dashboard loads at the workers.dev URL.

## Pitfalls
- If `/root/.hermes/memories` does not exist, the script falls back to `/root/ulak/memories` (the Ulak snapshot). Ensure at least one source is present.
- Ensure you copy from the correct directory name: use `memories` (plural) not `memory` (singular); the Ulak snapshot stores memories in `/root/ulak/memories/`.
- The aggregator may warn about missing macOS-only signals on Linux; this is expected and does not affect functionality.
- If `bun run build` fails due to missing dependencies, ensure the bun lockfile is up to date and run `bun install` first.
- Wrangler deployment may require authentication; ensure `wrangler login` has been run.

## References
- See `references/agentic-os-memory-sync.md` for details on memory synchronization.
- See `references/references/agentic-os-aggregator.md` for notes on the aggregate.ts script.
- See `references/deploy-2026-06-16.md` for the latest deployment log (2026-06-16).
- See `references/deploy-2026-06-15b.md` for the latest deployment log (2026-06-15).