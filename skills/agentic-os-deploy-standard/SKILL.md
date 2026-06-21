---
name: agentic-os-deploy-standard
description: Standard procedure for Agentic OS full refresh and deploy with Hermes memory sync.
category: devops
---
# Agentic OS Full Refresh and Deploy (Standard)

This skill outlines the steps to synchronize Hermes memory files, run the aggregator, build, and deploy the Agentic OS dashboard.

## Steps

1. **Sync Hermes memory files**
   - Source: `/root/ulak/memories/` (or `/root/.hermes/memories/`)
   - Copy to `/tmp/hermes-memory/`
   - ```bash
     mkdir -p /tmp/hermes-memory
cp -r /root/ulak/memories/. /tmp/hermes-memory/
     ```

2. **Run the aggregator**
   - Ensures the aggregator scans `~/.claude/projects`, `~/.claude/memory`, and `/tmp/hermes-memory/`
   - ```bash
     cd /root/code/agentic-os && bun run scripts/aggregate.ts
     ```

3. **Build**
   - ```bash
     cd /root/code/agentic-os && bun run build
     ```

4. **Deploy**
   - ```bash
     cd /root/code/agentic-os && wrangler deploy
     ```

## Verification
- Check the output for the deployed version ID.
- Confirm total memory files count (should be 2: MEMORY.md and USER.md).
- Ensure no errors are reported.

## Pitfalls
- If the source memory directory does not exist, the rsync will fail. Verify the path.
- The aggregator may skip macOS-only signals on Linux; this is expected.
- Ensure `bun` and `wrangler` are installed and in PATH.