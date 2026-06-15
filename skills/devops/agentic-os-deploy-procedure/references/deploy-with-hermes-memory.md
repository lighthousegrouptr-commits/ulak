# Deploy Agentic OS with Hermes Memory Sync (2026-06-15)

This reference documents the steps taken to sync Hermes memory files and deploy the Agentic OS dashboard.

## Steps
1. Sync memory files:
   ```bash
   mkdir -p /tmp/hermes-memory
   cp -r /root/ulak/memories/* /tmp/hermes-memory/
   ```
2. Run aggregator:
   ```bash
   cd /root/code/agentic-os && bun run scripts/aggregate.ts
   ```
3. Build:
   ```bash
   cd /root/code/agentic-os && bun run build
   ```
4. Deploy:
   ```bash
   cd /root/code/agentic-os && wrangler deploy
   ```

## Notes
- The aggregator script already checks multiple Hermes memory directories, including `/tmp/hermes-memory/`.
- Ensure the source directory `/root/ulak/memories/` contains the latest memory files (MEMORY.md, USER.md).