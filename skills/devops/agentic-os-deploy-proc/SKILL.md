---
name: agentic-os-deploy-proc
description: Procedure for Agentic OS full refresh and deploy with Hermes memory sync.
category: devops
---

# Agentic OS Full Refresh and Deploy Procedure

This skill outlines the steps to sync Hermes memory files, run the aggregator, build, and deploy the Agentic OS dashboard.

## Steps

1. Sync Hermes memory files to `/tmp/hermes-memory/`.
   - Copy from `/root/ulak/memories/` and `/root/.hermes/memories/` (if `/root/ulak/memory/` missing).

2. Run the aggregator:
   ```bash
   cd /root/code/agentic-os && bun run scripts/aggregate.ts
   ```

3. Build the application:
   ```bash
   cd /root/code/agentic-os && bun run build
   ```

4. Deploy via Wrangler:
   ```bash
   cd /root/code/agentic-os && wrangler deploy
   ```

## Verification

- Check aggregator output for memory file count.
- Note wrangler deploy version ID.

## Pitfalls

- Ensure source directories exist: `/root/ulak/memories/` and `/root/.hermes/memories/`.
- The aggregator may skip macOS-only signals on Linux (expected).
- Ensure working directory is `/root/code/agentic-os` before running aggregator, build, and deploy.
