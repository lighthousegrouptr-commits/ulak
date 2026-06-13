---
name: agentic-os-refresh-deploy
description: Refresh and deploy the Agentic OS dashboard by syncing Hermes memory files to a temporary location, then running the aggregator (which scans both the synced Hermes memories and the default Claude memories), building, and deploying.
---

## Trigger Conditions
When the user requests to run the Agentic OS full refresh and deploy, or when the Hermes memory files need to be synced and the Agentic OS dashboard rebuilt and redeployed.

## Steps

1. Ensure the temporary directory for Hermes memories exists:
   ```bash
   mkdir -p /tmp/hermes-memory
   ```

2. Copy the Hermes memory files from the Ulak project to the temporary directory:
   ```bash
   if [ -d /root/ulak/memories ]; then
     rsync -av /root/ulak/memories/ /tmp/hermes-memory/
   elif [ -d /root/.hermes/memories ]; then
     rsync -av /root/.hermes/memories/ /tmp/hermes-memory/
   else
     echo 'No Hermes memories directory found'
     exit 1
   fi
   ```
   *Note: If `rsync` is not available, `cp -a` works as well.*

3. (Optional) Count the number of memory files copied:
   ```bash
   find /tmp/hermes-memory -type f | wc -l
   ```

4. Change to the Agentic OS directory and run the aggregator:
   ```bash
   cd /root/code/agentic-os
   bun run scripts/aggregate.ts
   ```

5. Build the Agentic OS dashboard:
   ```bash
   bun run build
   ```

6. Deploy the dashboard to Cloudflare Workers:
   ```bash
   # For non-interactive deployment, set CI=true to avoid prompts
   CI=true wrangler deploy
   ```

## Pitfalls

- The aggregate.ts script may warn about macOS-only signals being skipped on Linux. This is expected and does not affect the aggregation of Hermes memories.
- The vite build may warn about some chunks being larger than 500 kB after minification. This is expected and does not affect the deployment.
- Ensure that the temporary directory /tmp/hermes-memory is writable and that you have permission to read the source memory directories.
- The wrangler deploy command may warn about missing workers_dev and preview_urls in the Wrangler file. These warnings can be ignored or addressed by adding the appropriate settings to wrangler.jsonc.
- If wrangler deploy prompts for confirmation (e.g., in CI environments), prefix the command with `CI=true` to run non-interactively.
- After building, the effective Wrangler configuration is located at `dist/server/wrangler.json`; ensure that any local changes to `wrangler.jsonc` are reflected there by rebuilding.

## Verification

- After deployment, the output will show a Version ID (e.g., f1951978-c6eb-4cd9-9340-f42b2f895afe).
- The total memory files count from the synced Hermes memories can be verified by the find command in step 3.
- The aggregator output will show a combined memory count (e.g., "memory: 18 files / 2 workspaces / 0 Pinecone indexes / 0 vectors / 8 events") that includes both the synced Hermes memories and the default Claude memories in ~/.claude/memory.