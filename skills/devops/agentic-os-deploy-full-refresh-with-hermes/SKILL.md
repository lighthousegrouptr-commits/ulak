---
name: agentic-os-deploy-full-refresh-with-hermes
description: Full refresh and deploy of Agentic OS dashboard with Hermes memory synchronization.
category: devops
version: 1.0.0
---

## When to Use

Use this skill when you want to refresh the Agentic OS dashboard with the latest data from both `~/.claude/` and Hermes memories, then build and deploy the dashboard to Cloudflare Workers.

## Prerequisites

- Hermes Agent installed and configured with memories in `~/.hermes/memories/`
- Agentic OS source code checked out at `/root/code/agentic-os`
- Bun and Wrangler installed
- Access to Cloudflare account for `wrangler deploy`

## Steps

1. **Sync Hermes memory files**
   - Create the temporary directory if it doesn't exist: `mkdir -p /tmp/hermes-memory`
   - Copy the Hermes memory files (only the `.md` files, ignoring lock files) from `~/.hermes/memories/` to `/tmp/hermes-memory/`:
     ```bash
     cp ~/.hermes/memories/MEMORY.md /tmp/hermes-memory/
     cp ~/.hermes/memories/USER.md /tmp/hermes-memory/
     ```
   - Verify the copy: `ls -la /tmp/hermes-memory/` (should show MEMORY.md and USER.md)

2. **Run the Agentic OS aggregator**
   - Change to the Agentic OS directory: `cd /root/code/agentic-os`
   - Run the aggregator script: `bun run scripts/aggregate.ts`
   - This script will scan:
     - `~/.claude/projects`
     - `~/.claude/memory`
     - `/tmp/hermes-memory` (the synced Hermes memories)
   - It will generate `/root/code/agentic-os/src/data/live-data.json`

3. **Build the dashboard**
   - Still in `/root/code/agentic-os`, run: `bun run build`
   - This will seed the data (if needed) and build the client and server bundles for production.

4. **Deploy to Cloudflare Workers**
   - Deploy the worker: `wrangler deploy`
   - Note: Do not use `--upload-source-map` as it is not a valid flag. The default behavior does not upload source maps, which is acceptable.
   - Upon success, note the version ID from the output.

## Verification

- After deployment, visit the deployed Worker URL (provided in the `wrangler deploy` output) to verify the dashboard is updated.
- Check that the Live Data section reflects the synced Hermes memories and Claude data.

## Pitfalls

- **Lock files**: Do not copy the lock files (`MEMORY.md.lock`, `USER.md.lock`) from `~/.hermes/memories/` as they are not needed by the aggregator and may cause confusion.
- **Wrangler deploy flags**: The flag `--upload-source-map` is invalid. Use `wrangler deploy` without any flags for a standard deployment. If you wish to control source map uploading, use the correct flag `--upload-source-maps` (with an 's') and set it to `false` if needed.
- **Aggregator output**: The aggregator may report skipping macOS-only signals on Linux. This is expected and does not affect the core functionality of scanning projects, memories, and skills.

## Troubleshooting

- If the aggregator fails to read the Hermes memories, verify that the files were copied correctly to `/tmp/hermes-memory/` and that they are readable.
- If the build fails, check for any missing dependencies and ensure bun is installed.
- If `wrangler deploy` fails, check your Cloudflare API token and ensure you are logged in (via `wrangler login`).

## Example

Here is an example of running the full refresh and deploy:

```bash
mkdir -p /tmp/hermes-memory
cp ~/.hermes/memories/MEMORY.md /tmp/hermes-memory/
cp ~/.hermes/memories/USER.md /tmp/hermes-memory/
cd /root/code/agentic-os
bun run scripts/aggregate.ts
bun run build
wrangler deploy
```

## References

- Agentic OS repository: `/root/code/agentic-os`
- Hermes memories: `~/.hermes/memories/`
- Wrangler documentation: https://developers.cloudflare.com/workers/wrangler/