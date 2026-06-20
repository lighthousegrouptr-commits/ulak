# Hermes Memory Sync for Agentic OS Deploy

This procedure syncs Hermes memory files from the Ulak snapshot to a temporary directory for the Agentic OS aggregator.

## Steps

1. **Ensure source directory exists**
   ```bash
   ls -la /root/ulak/memories/
   ```
   (Note: In the Ulak repo, memories are stored under `/root/ulak/memories/`)

2. **Create target directory**
   ```bash
   mkdir -p /tmp/hermes-memory
   ```

3. **Copy memory files**
   ```bash
   cp /root/ulak/memories/* /tmp/hermes-memory/
   ```

4. **Verify copy**
   ```bash
   find /tmp/hermes-memory -type f | wc -l   # should be 2 (MEMORY.md, USER.md) plus any lock files
   ```

5. **Run Agentic OS aggregator**
   ```bash
   cd /root/code/agentic-os && bun run scripts/aggregate.ts
   ```
   The aggregator will scan `~/.claude/projects`, `~/.claude/memory`, and `/tmp/hermes-memory/`.

6. **Build and deploy**
   ```bash
   bun run build   # or `bun run seed:data && vite build`
   bun run deploy  # wrangler deploy
   ```

## Notes

- The aggregator output includes a line like `memory: 23 files / 2 workspaces ...` indicating it picked up the synced memories.
- After deployment, check the live dashboard for updated memory file count.
