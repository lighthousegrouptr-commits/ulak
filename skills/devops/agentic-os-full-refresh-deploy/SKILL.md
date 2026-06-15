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
   # Prefer live Hermes memories; fallback to ulak memory directory if needed 
   if [ -d "/root/.hermes/memories" ]; then 
     cp -av /root/.hermes/memories/* /tmp/hermes-memory/ 
   elif [ -d "/root/ulak/memory" ]; then 
     cp -av /root/ulak/memory/* /tmp/hermes-memory/ 
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
   ```
   - This reads `~/.claude/projects`, `~/.claude/memory`, and `/tmp/hermes-memory/`.
   - Outputs `src/data/live-data.json`.

4. **Build the dashboard**
   ```bash
   bun run build
   ```
   - Produces production assets in `dist/`.

5. **Deploy via Wrangler**
   ```bash
   wrangler deploy
   ```
   - Deploys the Cloudflare Worker.
   - Outputs the deployed version ID.

## Verification
- After deployment, check the version ID in the wrangler output.
- Ensure the dashboard loads at the workers.dev URL.

## Pitfalls
- If `/root/.hermes/memories` does not exist, the script falls back to `/root/ulak/memory` (the Ulak snapshot). Ensure at least one source is present.
- The aggregator may warn about missing macOS-only signals on Linux; this is expected and does not affect functionality.
- If `bun run build` fails due to missing dependencies, ensure the bun lockfile is up to date and run `bun install` first.
- Wrangler deployment may require authentication; ensure `wrangler login` has been run.

## References
- See `references/agentic-os-memory-sync.md` for details on memory synchronization.
- See `references/agentic-os-aggregator.md` for notes on the aggregate.ts script.