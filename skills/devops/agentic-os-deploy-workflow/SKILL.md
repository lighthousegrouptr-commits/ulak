---
name: agentic-os-deploy-workflow
description: Full refresh and deploy of Agentic OS dashboard with Hermes memory sync.
version: 1
---

**Trigger**: When you need to refresh the Agentic OS dashboard with latest Hermes memories and redeploy the Cloudflare Worker.

**Steps**:

1. **Sync Hermes memory files**
   - Ensure the temporary directory exists: `mkdir -p /tmp/hermes-memory`
   - Copy memory files from the Hermes/Ulak memories directory:
     ```bash
     cp -r /root/ulak/memories/* /tmp/hermes-memory/ 2>/dev/null || true
     ```
   - Verify the copy: `find /tmp/hermes-memory -type f -name "*.md" | wc -l` (should be 2)

2. **Run the aggregator**
   - Change to the agentic-os directory and run the TypeScript aggregator:
     ```bash
     cd /root/code/agentic-os && bun run scripts/aggregate.ts
     ```
   - This scans `~/.claude/`, `~/.claude/memory/`, and `/tmp/hermes-memory/` and writes `src/data/live-data.json`.

3. **Build the project**
   - Still in `/root/code/agentic-os`, run:
     ```bash
     bun run build
     ```
   - This will seed data if needed and produce a production Vite build.

4. **Deploy via Wrangler**
   - Deploy the built worker:
     ```bash
     cd /root/code/agentic-os && wrangler deploy
     ```
   - Note the version ID from the output (e.g., `Current Version ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`).

**Verification**:
- After deployment, the dashboard should be live at the workers.dev URL shown in the deploy output.
- Check that the memory count in the aggregator log includes the synced Hermes files (look for `memory: X files / ...`).

**Pitfalls**:
- The source directory for Hermes memories is `/root/ulak/memories/` (not `/root/ulak/memory/`). Using the wrong path results in zero files copied.
- If `/tmp/hermes-memory/` is not cleaned between runs, old files may linger; the aggregator will still process them but it's safe to wipe the directory first.
- The aggregator may warn about missing macOS-specific signals on Linux; this is expected and does not affect the core data.
- Ensure `bun` is installed and the project dependencies are up-to-date; otherwise `bun run build` may fail.

**References**:
- See `references/memory-sync-detail.md` for the exact memory folder structure observed in a typical session.