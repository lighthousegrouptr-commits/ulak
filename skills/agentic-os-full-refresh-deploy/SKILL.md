---
name: agentic-os-full-refresh-deploy
description: Refresh Agentic OS dashboard by syncing Hermes memories and deploying the dashboard.
---

# Agentic OS Full Refresh and Deploy

Refresh the Agentic OS dashboard by syncing Hermes memories and deploying the updated dashboard.

## When to Use

Use this skill when you want to update the Agentic OS dashboard with the latest Hermes memories
and deploy the changes.

## Steps

1. **Prepare the temporary Hermes memory directory**:
   - Create `/tmp/hermes-memory` if it doesn't exist.
   - Copy Hermes memory files from known locations to this temporary directory.
     The aggregator script checks multiple sources, but we copy to ensure consistency.

   ```bash
   mkdir -p /tmp/hermes-memory
   # Copy from Ulak project memories (if exists)
   cp -r /root/ulak/memories/* /tmp/hermes-memory/ 2>/dev/null || true
   # Copy from Hermes memories (if exists)
   cp -r /root/.hermes/memories/* /tmp/hermes-memory/ 2>/dev/null || true
   # Also check the non-pluralized directory names (just in case)
   cp -r /root/ulak/memory/* /tmp/hermes-memory/ 2>/dev/null || true
   cp -r /root/.hermes/memory/* /tmp/hermes-memory/ 2>/dev/null || true
   ```

2. **Run the aggregator** to scan ~/.claude/, ~/.claude/memory, and /tmp/hermes-memory/:
   ```bash
   cd /root/code/agentic-os
   bun run scripts/aggregate.ts
   ```

3. **Build and deploy**:
   ```bash
   bun run build
   wrangler deploy
   ```

## Pitfalls

- **Source directory may not exist**: The directory `/root/ulak/memory` might not exist. 
  Instead, look for memories in `/root/ulak/memories` and `/root/.hermes/memories` (and their singular forms).
  The copy commands above use `|| true` to avoid errors if the source is missing.

- **Verify the aggregator output**: After running the aggregator, check the output for the number of memory files
  processed to ensure the sync worked.

## Verification

After deployment, check the version ID from the `wrangler deploy` output and confirm the dashboard is updated.

## Required Tools

- bun
- wrangler
- Access to the Agentic OS source code at `/root/code/agentic-os`
- Hermes memories in `/root/ulak/memories` and/or `/root/.hermes/memories`
