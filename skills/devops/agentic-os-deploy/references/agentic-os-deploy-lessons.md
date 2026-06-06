# Agentic OS Deploy Lessons Learned

## Memory Sync Source
Hermes agent memories are synchronized from `~/.hermes/` to `/root/ulak/` via the `ulak_sync.sh` script (run every 30 minutes via cron). Therefore, when syncing Hermes memory files for the Agentic OS aggregator, the correct source is `/root/ulak/memory/`, not `~/.hermes/memory/`.

## Steps
1. Sync Hermes memory files:
   - Source: `/root/ulak/memory/`
   - Destination: `/tmp/hermes-memory/`
   - Command: `cp -r /root/ulak/memory/* /tmp/hermes-memory/`

2. Run aggregator:
   - `cd /root/code/agentic-os && bun run scripts/aggregate.ts`

3. Build:
   - `bun run build`

4. Deploy:
   - `wrangler deploy`

## Notes
- The aggregator script expects Hermes memories in `/tmp/hermes-memory/` (as set by `HERMES_MEMORIES_DIR` constant).
- Ensure the destination directory exists before copying.