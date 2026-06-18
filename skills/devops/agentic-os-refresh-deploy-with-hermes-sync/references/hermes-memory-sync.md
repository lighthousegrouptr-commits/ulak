# Hermes Memory Sync for Agentic OS

This procedure syncs Hermes memory files from the live Hermes agent (~/.hermes/memories) to a temporary location for the Agentic OS aggregator.

## Steps

1. Ensure destination directory exists:
   ```bash
   mkdir -p /tmp/hermes-memory
   ```

2. Copy memory files (preserving attributes):
   ```bash
   cp -r /root/ulak/memories/* /tmp/hermes-memory/
   ```
   Note: The source path `/root/ulak/memories` is the synced snapshot of `~/.hermes/memories` on this machine.

3. Verify files were copied:
   ```bash
   find /tmp/hermes-memory -type f -name "*.md" | wc -l
   ```
   Should return 2 (MEMORY.md and USER.md) plus any additional memory files.

4. Proceed with running the Agentic OS aggregator:
   ```bash
   cd /root/code/agentic-os && bun run scripts/aggregate.ts
   ```

The aggregator will then scan both `~/.claude/` and `/tmp/hermes-memory/` as configured.

## Notes

- The `/root/ulak/memories` directory is updated every 30 minutes via the `ulak_sync.sh` cron job.
- If syncing directly from `~/.hermes/memories`, adjust the source path accordingly.
- Lock files (`*.lock`) may be present; they are harmless and can be ignored.