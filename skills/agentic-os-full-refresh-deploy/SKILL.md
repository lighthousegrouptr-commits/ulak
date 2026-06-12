---
name: agentic-os-full-refresh-deploy
description: Refresh Agentic OS dashboard by syncing Hermes memories and rebuilding deployment.
trigger:
  - user wants to update Agentic OS dashboard with latest Hermes memories
  - after changes to Hermes memories or skills
---

## Agentic OS Full Refresh and Deploy

 Refresh the Agentic OS dashboard by syncing Hermes memory files and rebuilding the deployment.

 ## Steps
1. **Sync Hermes memory files**
   - Ensure the target directory exists: `mkdir -p /tmp/hermes-memory`
   - Copy memory files from the Ulak snapshot: `cp -r /root/ulak/memories/. /tmp/hermes-memory/` (the Ulak snapshot lives at `/root/ulak/memories/`; note that `/root/ulak/memory` (singular) does not exist; the live Hermes memories are at `~/.hermes/memories/` and the aggregator also checks `/root/.hermes/memories/`, `/root/ulak/memories/`, and `/tmp/hermes-memory/` directly, so copying to `/tmp/hermes-memory/` is optional but ensures the latest snapshot is available.)
   - Note: lock files (`*.md.lock`) are harmless and can be ignored.
   - **Verification:** After copying, confirm files are present: `ls -1 /tmp/hermes-memory/*.md 2>/dev/null | wc -l` returns the number of memory files copied (aggregator will also see memories from other sources).

2. **Run the aggregator**
   - Change to the agentic-os directory: `cd /root/code/agentic-os`
   - Execute the aggregation script: `bun run scripts/aggregate.ts`
   - This script scans ~/.claude/projects, ~/.claude/memory, and /tmp/hermes-memory/ to generate live-data.json

3. **Build and deploy**
   - Build the project: `bun run build`
   - Deploy to Cloudflare Workers: `wrangler deploy`
   - Note the deployed version ID from the output.

## Pitfalls
- The aggregator script already includes multiple Hermes memory source paths in its configuration (including `/tmp/hermes-memory`, `/root/.hermes/memories`, and `/root/ulak/memories`), so copying to `/tmp/hermes-memory` is sufficient but not strictly required if other paths are already populated.
- If no memory files are found, the aggregator will still run but the memory constellation in the dashboard will be empty.
- Ensure you have `bun` and `wrangler` installed and configured in the agentic-os directory.
- The deploy step may fail if Cloudflare Workers authentication is not set up; check `wrangler login` status if needed.
- Double-check the source directory name: it is `memories` (plural) under `/root/ulak/`; `/root/ulak/memory` (singular) does not exist and will cause the copy to fail.
- If `wrangler deploy` fails with a Cloudflare API error (e.g., code 10013), verify your Cloudflare authentication with `wrangler login` and check network connectivity; transient API issues may resolve with a retry.

## Verification
- Check the output of `wrangler deploy` for the Version ID (e.g., `Current Version ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`).
- Count the number of memory files synced: `ls -1 /tmp/hermes-memory/ | wc -l`
- Review the aggregator output for any errors (look for lines starting with `[aggregate]`).
- The dashboard should update within a few minutes after deployment.

## Example Output
```
[aggregate] wrote /root/code/agentic-os/src/data/live-data.json
[aggregate] subs: claude=api_key chatgpt=none openrouter=missing openclaw=missing
[aggregate] value extracted last 7d: $0.11
...
✨ Success! Uploaded 21 files (54 already uploaded) (3.12 sec)
...
Current Version ID: cadbcfb9-8cd1-476f-aa3f-434606052a42
```
```