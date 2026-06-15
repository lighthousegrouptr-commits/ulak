# Memory Synchronization Notes

The Agentic OS aggregator expects Hermes memories in `/tmp/hermes-memory/`.
The sync step copies either live Hermes memories (`~/.hermes/memories/`) or,
if unavailable, the Ulak Git‑synced snapshot (`/root/ulak/memories/`).

Only `.md` files are relevant for the memory graph; lock files (`.md.lock`)
are ignored by the aggregator.

After syncing, a quick verification is to count the Markdown files:

```bash
find /tmp/hermes-memory -name "*.md" -type f | wc -l
```

This should match the number of memory files in the source directory.