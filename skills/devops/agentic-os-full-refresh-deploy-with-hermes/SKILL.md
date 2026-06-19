---
name: agentic-os-full-refresh-deploy-with-hermes
category: devops
description: Perform a full refresh of the Agentic OS dashboard by syncing Hermes memory files, running the aggregator, building, and deploying via Wrangler.
---

## Steps

1. **Sync Hermes memory files**
   - Ensure the source directory exists: `/root/ulak/memories/` (or `~/.hermes/memories/` depending on setup).
   - Create the target directory if needed: `mkdir -p /tmp/hermes-memory`
   - Copy memory files: `cp /root/ulak/memories/* /tmp/hermes-memory/`
   - Verify files were copied (should include MEMORY.md, USER.md, and optionally a memories/ subdirectory with additional memory files).
   - Optionally check file count: `find /tmp/hermes-memory -type f | wc -l` (expected: at least 2 for MEMORY.md and USER.md, plus any additional memory files).

2. **Run the aggregator**
   - Change to the Agentic OS directory: `cd /root/code/agentic-os`
   - Execute the aggregation script: `bun run scripts/aggregate.ts`
   - This reads `~/.claude/projects`, `~/.claude/memory`, and `/tmp/hermes-memory/` (as configured in the script) and updates `src/data/live-data.json`.

3. **Build the application**
   - Run: `bun run build`
   - This will seed data if needed and produce a production build in the `dist/` directory.

4. **Deploy via Wrangler**
   - Deploy the worker: `wrangler deploy`
   - Note the version ID from the output for reporting.

## Verification
- After deployment, the Agentic OS dashboard should be accessible at the configured workers.dev subdomain.
- Check that the live-data.json includes data from Hermes memories (look for memory-related sections in the dashboard).

## Pitfalls
- If the Hermes memory source path is different, adjust the copy command accordingly.
- The aggregator script may warn about missing macOS-only signals on Linux; this is expected and does not affect functionality.
- Ensure you have the necessary permissions to read the source memory files and write to `/tmp/hermes-memory`.
- Wrangler deployment requires a configured Cloudflare account; ensure `wrangler login` has been run and the correct project is selected.

## Related Skills
- `agentic-os-deploy`: Basic deployment without memory sync.
- `hermes-agent`: For configuring Hermes Agent itself.