---
name: agentic-os-refresh-deploy
description: Refresh and deploy the Agentic OS dashboard by syncing Hermes memory files, running the aggregator, building, and deploying.
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
   cp -r /root/ulak/memories/* /tmp/hermes-memory/
   ```

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
   wrangler deploy
   ```

## Pitfalls

- The aggregate.ts script may warn about macOS-only signals being skipped on Linux. This is expected and does not affect the aggregation of Hermes memories.
- Ensure that the temporary directory /tmp/hermes-memory is writable and that you have permission to read the source memory directories.
- The wrangler deploy command may warn about missing workers_dev and preview_urls in the Wrangler file. These warnings can be ignored or addressed by adding the appropriate settings to wrangler.jsonc.

## Verification

- After deployment, the output will show a Version ID (e.g., cb09d0bb-af0b-425c-af08-df8986849b30).
- The total memory files count can be verified by the find command in step 3.