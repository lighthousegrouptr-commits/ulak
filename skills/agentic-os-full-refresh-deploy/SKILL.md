---
name: agentic-os-full-refresh-deploy
description: Refresh Agentic OS dashboard with Hermes memories and deploy via Wrangler.
version: 1.0
---

# Agentic OS Full Refresh and Deploy

**Trigger**: When you need to refresh the Agentic OS dashboard with the latest Hermes memories and redeploy via Wrangler.

## Steps

1. **Prepare memory sync directory**
   ```bash
   mkdir -p /tmp/hermes-memory
   ```

2. **Sync Hermes memory files**
   - Source: `/root/ulak/memories/` (note: the directory is `memories`, not `memory`)
   - Copy all files:
     ```bash
     cp -r /root/ulak/memories/* /tmp/hermes-memory/
     ```
   - If the source directory is empty, the copy will produce no files; that's okay.

3. **Count synced memory files**
   ```bash
   find /tmp/hermes-memory -type f | wc -l
   ```
   Record this count for the report.

4. **Run the aggregator** (scans `~/.claude/` and synced Hermes memories)
   ```bash
   cd /root/code/agentic-os && bun run scripts/aggregate.ts
   ```
   - This updates `src/data/live-data.json` with data from both sources.

5. **Build the project**
   - First, verify that a `build` script exists in `package.json`:
     ```bash
     cd /root/code/agentic-os && bun run
     ```
   - Look for a `build` entry under `scripts`. If present, run:
     ```bash
     bun run build
     ```
   - If no `build` script is present, check for alternative build commands (e.g., `bun run build:prod`, `bun build`) and adjust accordingly.
   - If the build fails, check the error output and ensure dependencies are installed (`bun install`).

6. **Deploy via Wrangler**
   ```bash
   wrangler deploy
   ```
   - Capture the deployed version ID from the output (look for a line like `Deployed <project> (<version_id>)`).

7. **Report**
   - Deployed version ID
   - Total memory files count (from step 3)
   - Any errors encountered during sync, aggregation, build, or deploy

## Notes

- The Hermes agent memories are stored in `/root/ulak/memories/` on this system (mirrored from `~/.hermes/memories/`).
- The `ulak` directory is a GitHub-backed snapshot of `~/.hermes/`; the actual live memories live in `~/.hermes/memories/` but are copied to `/root/ulak/memories/` by the sync cron job.
- If the `memories` directory is missing or empty, the aggregator will still work but will not include Hermes memory data.
- Always verify the build script exists before running `bun run build` to avoid "Script not found" errors.
- A helper script is available at `scripts/agentic-os-refresh-deploy.sh` that performs the sync, aggregate, build, deploy and reports the version ID and memory file count.