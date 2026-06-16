# Hermes Memory Sync for Agentic OS

## Purpose
This reference details how to synchronize Hermes memory files from the Ulak snapshot (`/root/ulak/memories/`) to the temporary location (`/tmp/hermes-memory/`) used by the Agentic OS aggregator.

## Why Sync from `/root/ulak/memories/`?
- The live Hermes memories reside in `~/.hermes/memories/`.
- The Ulak snapshot in `/root/ulak/memories/` is updated every 30 minutes via the `ulak_sync.sh` cron job (which copies from `~/.hermes/` to `/root/ulak/` and pushes to GitHub).
- Using the snapshot ensures:
  - Consistency: The aggregator reads a stable point-in-time copy.
  - Availability: The snapshot is guaranteed to exist on this machine (the cron job runs regardless of user presence).
  - Safety: Avoids reading from the live directory while it might be mid-sync or locked.

## Procedure
```bash
# Ensure the target directory exists
mkdir -p /tmp/hermes-memory

# Copy all memory files from the Ulak snapshot
cp /root/ulak/memories/* /tmp/hermes-memory/
```

## Notes
- The aggregator script (`/root/code/agentic-os/scripts/aggregate.ts`) explicitly scans `/tmp/hermes-memory/` as one of its memory sources (alongside `~/.claude/projects` and `~/.claude/memory`).
- If the snapshot directory is empty or missing, check that the ulak_sync.sh cron job has run recently (it runs every 30 minutes). You can trigger a manual sync with:
  ```bash
  bash ~/.hermes/scripts/ulak_sync.sh
  ```
- After copying, verify the files exist:
  ```bash
  ls -la /tmp/hermes-memory/
  ```
  You should see at least `MEMORY.md` and `USER.md` (and potentially other memory files if present).

## Troubleshooting
- **Permission denied**: Ensure you have read access to `/root/ulak/memories/` and write access to `/tmp/hermes-memory/`.
- **No such file or directory**: Verify the source path `/root/ulak/memories/` exists. If not, the Ulak repository may not be cloned or the sync job failed.
- **Aggregator fails to read memories**: Ensure the copied files are readable (they should be `-rw-------` as copied). The aggregator runs as the same user, so permissions should be fine.