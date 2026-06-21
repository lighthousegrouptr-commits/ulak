# Memory Sync Verification

When syncing Hermes memory files to `/tmp/hermes-memory/`, you can verify the number of meaningful memory files (excluding lock files) with:

```bash
find /tmp/hermes-memory -type f -not -name '*.lock' | wc -l
```

This count should match the "memory: X files" line shown by the Agentic OS aggregator script output.