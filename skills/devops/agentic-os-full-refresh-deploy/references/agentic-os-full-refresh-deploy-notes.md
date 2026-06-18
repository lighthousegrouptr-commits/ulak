# Agentic OS Full Refresh and Deploy - Session Notes

## Correction: Hermes Memory Source Path
- The Hermes memory files are located at `/root/ulak/memories/` (not `/root/ulak/memory/`).
- Copy all *.md files from this directory to `/tmp/hermes-memory/` before running the aggregator.

## Aggregator Command
- After copying memories, run the aggregator from the agentic-os directory:
  ```bash
  cd /root/code/agentic-os && bun run scripts/aggregate.ts
  ```
- The aggregator scans:
  - `~/.claude/projects`
  - `~/.claude/memory`
  - `/tmp/hermes-memory/` (the synced Hermes memories)

## Build and Deploy
- Build the dashboard:
  ```bash
  bun run build
  ```
- Deploy via Wrangler:
  ```bash
  wrangler deploy
  ```

## Outputs to Record
- Deployed version ID (from wrangler deploy output)
- Total memory files count (number of *.md files copied)
- Any errors during sync, aggregation, build, or deploy

## Example Session Outcome
- Deployed version ID: `492b5e6d-aa55-41f6-b82f-2fb00990ac1d`
- Total memory files count: 2 (MEMORY.md, USER.md)
- Errors: Initial sync failed due to incorrect source path; corrected and succeeded.