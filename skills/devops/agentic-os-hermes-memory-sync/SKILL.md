---
name: agentic-os-hermes-memory-sync
description: Sync Hermes memory files to temporary location for Agentic OS aggregation.
category: devops
---

# Agentic OS Hermes Memory Sync

Skill for synchronizing Hermes agent memories with Agentic OS dashboard.

## When to Use
Before running the Agentic OS aggregator to ensure it picks up the latest Hermes memories.

## Procedure
```bash
# Create target directory if needed
mkdir -p /tmp/hermes-memory

# Sync memories from Hermes agent to temporary location
# Important: Source is ~/.hermes/memories (not /root/ulak/memory)
cp -r ~/.hermes/memories/* /tmp/hermes-memory/

# Verify sync completed
ls -la /tmp/hermes-memory/
# Should show MEMORY.md, USER.md and their lock files
```

## Notes
- The Agentic OS aggregator script automatically scans `/tmp/hermes-memory/` as a memory source
- Typical memory files: MEMORY.md (agent memories), USER.md (user preferences)
- Lock files (.lock) are temporary and can be ignored
- This sync should be run fresh each time before aggregation to avoid stale data
- **Important**: The initial instruction to sync from `/root/ulak/memory/` was incorrect - the actual Hermes memory location is `~/.hermes/memories/`
- **Important**: The initial instruction to sync from `/root/ulak/memory/` was incorrect - the actual Hermes memory location is `~/.hermes/memories/`

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