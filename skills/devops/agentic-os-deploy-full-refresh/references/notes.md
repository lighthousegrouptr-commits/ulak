# Notes on Agentic OS Full Refresh and Deploy

## Memory Sync Details
- Source: /root/ulak/memories/ (contains MEMORY.md and USER.md, plus optional lock files)
- Destination: /tmp/hermes-memory/
- Lock files (*.lock) are ignored; they are created by the Hermes memory system and should not be counted.

## Aggregator Command Variations
- Default run: `bun run scripts/aggregate.ts`
- To force a rescan of all sources (including memory) you can delete src/data/live-data.json before running.

## Build and Deploy Tips
- If you encounter "Error: Cannot find module 'node:crypto'" ensure you are using a compatible Bun version.
- Wrangler may prompt to log in; ensure you have `wrangler login` done beforehand.
- To preview before deploying: `wrangler dev` (local development).

## Version ID Extraction
After `wrangler deploy`, the line:
```
Current Version ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```
is the identifier to report.

## Error Handling
- If aggregator fails due to missing ~/.claude/ directory, ensure Claude Code is installed and has data.
- If build fails due to missing dependencies, run `bun install` first.
- If deploy fails due to authentication, run `wrangler login` and retry.
