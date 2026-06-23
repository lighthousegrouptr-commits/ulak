---
name: agentic-os-deploy-full-refresh
description: Perform a full refresh of the Agentic OS dashboard by syncing Hermes memory files, running the aggregator, building, and deploying via Wrangler.
---

# Agentic OS Full Refresh and Deploy

Perform a full refresh of the Agentic OS dashboard by syncing Hermes memory files, running the aggregator, building, and deploying via Wrangler.

## Trigger Conditions
- User requests to refresh and deploy the Agentic OS dashboard.
- After updating Hermes memories or skills and wanting to reflect changes in the dashboard.
- Periodic maintenance via cron job.

## Steps
1. **Prepare memory sync directory**
   ```bash
   mkdir -p /tmp/hermes-memory
   ```

2. **Sync Hermes memory files (exclude lock files)**
   ```bash
   # Copy only the actual memory files (MEMORY.md, USER.md), excluding lock files
   find /root/ulak/memories -maxdepth 1 -type f -name "*.md" -exec cp {} /tmp/hermes-memory/ \;
   # Alternative if find is unavailable: cp /root/ulak/memories/*.md /tmp/hermes-memory/
   # Verify count of synced memory files (should be 2: MEMORY.md and USER.md)
   find /tmp/hermes-memory -type f ! -name "*.lock" | wc -l
   ```

3. **Run the aggregator to scan ~/.claude/, ~/.claude/memory, and /tmp/hermes-memory/**
   ```bash
   cd /root/code/agentic-os
   bun run scripts/aggregate.ts
   ```
   - The aggregator will output statistics about scanned files, projects, memory, etc.
   - Ensure it reports scanning memory folders and includes the synced Hermes memories.

4. **Build the dashboard for production**
   ```bash
   bun run build
   ```
   - This runs `seed:data` (copies example live-data if missing) and `vite build`.
   - Watch for warnings about large chunks; they are non-fatal.

5. **Deploy via Wrangler**
   ```bash
   wrangler deploy
   ```
   - Note the deployed Version ID from the output.
   - Confirm success: "Uploaded X files" and "Success!" message.

## Verification
- **Deployed version ID**: captured from `wrangler deploy` output (look for `Current Version ID:`).
- **Total memory files count**: output of the `find` command in step 2 (should be 2).
- **Errors**: any non-zero exit codes or error messages in the above steps; treat as failures.

## Pitfalls & Troubleshooting
- **Lock files causing false counts**: lock files (`*.lock`) appear in the memories directory; exclude them when counting.
- **User often misremembers the source path**: the user may say `/root/ulak/memory/` but the correct path is `/root/ulak/memories/` (with 'i'). Always check the actual path with `ls -la /root/ulak/memories/` before copying; do NOT follow the user's typo blindly.
- **Empty glob edge case**: if `cp *.md /tmp/hermes-memory/` fails because `*.md` doesn't match (e.g., zero files or unexpected filenames), fall back to explicit `find`-based copy or individual file copies.
- **Aggregator skipping macOS-only signals**: expected on Linux; not an error.
- **Wrangler warnings about `workers_dev` and `preview_urls`**: can be ignored or explicitly set in wrangler config if desired.
- **Build warnings about chunk size >500 KB**: non-fatal; consider enabling manual chunking if deployment size becomes problematic.
- **Missing `.env.local` for API keys**: aggregator will note missing keys; dashboard still works but some features (Pinecone, OpenRouter) disabled.

## References
- See `references/agentic-os-deploy-notes.md` for additional context and command variations.
