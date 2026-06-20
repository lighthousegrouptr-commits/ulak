---
name: agentic-os-hermes-memory-sync
description: Sync Hermes memory files to temporary location for Agentic OS aggregation.
category: devops
---

# Agentic OS Hermes Memory Sync

When preparing data for the Agentic OS dashboard, Hermes memory files must be copied to `/tmp/hermes-memory/` so the aggregator script can pick them up from both `~/.claude/` and Hermes agent memories.

## Steps

1. Ensure the temporary directory exists:
   ```bash
   mkdir -p /tmp/hermes-memory
   ```

2. Copy memory files from the Hermes memories directory (prefer live memories, fallback to Ulak backup):
   ```bash
   # Prefer live Hermes memories if available, otherwise use Ulak backup
   if [ -d ~/.hermes/memories ]; then
     echo "Syncing from live Hermes memories: ~/.hermes/memories"
     cp -r ~/.hermes/memories/* /tmp/hermes-memory/
   else
     echo "Falling back to Ulak backup: /root/ulak/memories"
     cp -r /root/ulak/memories/* /tmp/hermes-memory/
   fi
   ```

3. Remove any lock files that may have been copied (to keep sync directory clean):
   ```bash
   find /tmp/hermes-memory -name '*.lock' -delete
   ```

4. Verify the copy succeeded by counting files (excluding lock files for accurate count of meaningful memory files):
   ```bash
   find /tmp/hermes-memory -type f -not -name "*.lock" | wc -l
   ```

## Pitfalls

- Do not copy from `/root/ulak/memory/` as that directory may not exist or may be outdated. The live Hermes memories are stored in `~/.hermes/memories/` (or mirrored at `/root/ulak/memories/`). The skill now checks both locations automatically.
- The aggregator script also checks `/root/ulak/memory`, `/root/ulak/memories`, `/root/.hermes/memories`, `/root/.hermes/memory`, and `/tmp/hermes-memory`. Providing the files in `/tmp/hermes-memory/` ensures they are picked up regardless of other sources.