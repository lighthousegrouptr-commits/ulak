# Hermes Memory Sync Details

When preparing to run the Agentic OS aggregator, Hermes memory files must be synchronized from the Ulak snapshot located at `/root/ulak/memories/`. This directory is populated every 30 minutes by the `ulak_sync.sh` cron job, which copies filtered memories from `~/.hermes/memories/`.

The sync command used in the deployment procedure is:

```bash
mkdir -p /tmp/hermes-memory
cp -r /root/ulak/memories/* /tmp/hermes-memory/ 2>/dev/null || true
```

* Why `/tmp/hermes-memory`?  
  The aggregator script (`scripts/aggregate.ts`) explicitly looks for this path (see `HERMES_MEMORIES_DIR` constant) to include Hermes-specific memory files alongside Claude's native memory folders.

* What files are copied?  
  Only `.md` memory files (e.g., `MEMORY.md`, `USER.md`) are present in the source. Lock files (`*.md.lock`) may also appear but are ignored by the aggregator.

* Verification  
  After copying, you can verify the count with:
  ```bash
  find /tmp/hermes-memory -type f -name "*.md" | wc -l
  ```
  This should match the number of memory files in `/root/ulak/memories/`.

* Pitfalls  
  - If the source directory appears empty, ensure the Ulak sync cron job has run recently (`hermes cron list`).
  - The aggregator will still run successfully with zero Hermes memory files; it will simply report lower counts.