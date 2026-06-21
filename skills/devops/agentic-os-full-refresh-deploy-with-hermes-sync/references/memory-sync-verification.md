# Memory Sync Verification

When syncing Hermes memory files to `/tmp/hermes-memory/`, you can verify the number of meaningful memory files (excluding lock files) with:

```bash
find /tmp/hermes-memory -type f -not -name '*.lock' | wc -l
```

This count should match the Hermes memory files contribution to the `"memory: X files"` line shown by the Agentic OS aggregator script output. Note that the aggregator's memory count includes both `~/.claude/memory/` and `/tmp/hermes-memory/` (excluding lock files). To see only the Hermes memory files count, look for the line in the aggregator output that says `scanning memory folders ...` and then the subsequent line that gives the breakdown (if available) or rely on the verification command above.

Example from a run:
```
[aggregate] scanning memory folders ...
[aggregate] memory: 25 files / 2 workspaces / 0 Pinecone indexes / 0 vectors / 10 events
[aggregate] dream: 4 prescription(s) from 2026-06-21
...
```
In this example, the Hermes memory files synced were 2 (MEMORY.md and USER.md), and the Claude Code memory files were 23, totaling 25.