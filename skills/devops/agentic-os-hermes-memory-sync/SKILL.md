---
name: agentic-os-hermes-memory-sync
description: Sync Hermes memory files to temporary location for Agentic OS aggregation.
category: devops
---

# Agentic OS Hermes Memory Sync

When preparing data for the Agentic OS dashboard, Hermes memory files must be copied to `/tmp/hermes-memory/` so the aggregator script can pick them up.

## Steps

1. Ensure the temporary directory exists:
   ```bash
   mkdir -p /tmp/hermes-memory
   ```

2. Copy memory files from the Hermes memories directory (note: the correct source is `/root/ulak/memories/`, not `/root/ulak/memory/`):
   ```bash
   cp -r /root/ulak/memories/* /tmp/hermes-memory/
   ```

3. Verify the copy succeeded by counting files:
   ```bash
   find /tmp/hermes-memory -type f | wc -l
   ```

## Pitfalls

- Do not copy from `/root/ulak/memory/` as that directory may not exist or may be outdated. The live Hermes memories are stored in `/root/ulak/memories/` (or `~/.hermes/memories/` depending on setup). The Ulak snapshot mirrors `~/.hermes/` under `/root/ulak/`.
- The aggregator script also checks `/root/ulak/memory`, `/root/ulak/memories`, `/root/.hermes/memories`, `/root/.hermes/memory`, and `/tmp/hermes-memory`. Providing the files in `/tmp/hermes-memory/` ensures they are picked up regardless of other sources.