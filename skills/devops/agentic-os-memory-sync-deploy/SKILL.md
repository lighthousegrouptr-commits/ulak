---
name: agentic-os-memory-sync-deploy
category: devops
description: Sync Hermes memories to temp location, run Agentic OS aggregator, build, and deploy.
---

# Agentic OS Memory Sync and Deploy

Sync Hermes memories to a temporary location, run the Agentic OS aggregator, build, and deploy the dashboard.

## When to Use
- After updating Hermes memories or skills and you need the Agentic OS dashboard to reflect them.
- As part of a refresh workflow before deploying Agentic OS updates.

## Steps
1. **Create sync directory**
   ```bash
   mkdir -p /tmp/hermes-memory
   ```
2. **Sync Hermes memories**
   - Prefer live Hermes memories at `~/.hermes/memories/`.
   - Fallback to Ulak snapshot at `/root/ulak/memories/` if live path missing.
   ```bash
   if [ -d ~/.hermes/memories ]; then
     rsync -av ~/.hermes/memories/ /tmp/hermes-memory/
   else
     rsync -av /root/ulak/memories/ /tmp/hermes-memory/
   fi
   ```
3. **Run aggregator** (scans `~/.claude/` and synced Hermes memories)
   ```bash
   cd /root/code/agentic-os
   bun run scripts/aggregate.ts
   ```
4. **Build production bundle**
   ```bash
   bun run build
   ```
5. **Deploy via Wrangler**
   ```bash
   wrangler deploy
   ```
6. **Report**
   - Deployed version ID (from wrangler output)
   - Total memory files count: `find /tmp/hermes-memory -type f | wc -l`
   - Any errors from the above steps

## Pitfalls
- If both memory sources are missing, aggregator runs without Hermes memory data.
- Ensure write access to `/tmp/hermes-memory/` and the Agentic OS project directory.
- Aggregator may skip macOS‑specific signals on Linux; this is expected.

## Verification
After deployment, check `src/data/live-data.json`:
- Contains a memory source with `kind: "hermes"` and `root: "/tmp/hermes-memory"`.
- Memory node count reflects synced files.
