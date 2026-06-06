# Memory Synchronization Details

## Source Location
The Hermes agent memories are synchronized from the live Hermes instance at `~/.hermes/` to the GitHub-backed snapshot at `/root/ulak/` via the `ulak_sync.sh` script (runs every 30 minutes via cron).

## Files Copied
During the sync process, the following files and directories are copied from `~/.hermes/` to `/root/ulak/`:
- `SOUL.md` - Agent identity and persona definition
- `memories/` - Directory containing `MEMORY.md` (agent memories) and `USER.md` (user profile)
- `skills/` - Custom skills directory
- `cron/jobs.json` - Scheduled job definitions
- Various hooks and configuration files (with secrets filtered)

## Memory File Format
- `MEMORY.md`: Agent's persistent notes and learned facts (target: 'memory')
- `USER.md`: User preferences, role, communication style (target: 'user')
- Both files use plain markdown format with durable facts that survive across sessions.

## Filtering Process
The `ulak_sync.sh` script filters out sensitive information before committing to git:
- Lines matching `api_key|password|secret|token|TOKEN|SECRET|PASSWORD` are removed from `config.yaml`
- This ensures no secrets are stored in the GitHub repository

## Usage in Agentic OS
The Agentic OS aggregator script (`scripts/aggregate.ts`) specifically:
1. Reads from `~/.claude/projects` and `~/.claude/memory` (Claude Code native data)
2. Additionally scans `/tmp/hermes-memory/` (the synced Hermes memories)
3. Combines both sources into a unified memory store for the dashboard

## Synchronization Timing
- The cron job runs every 30 minutes (job ID: `925ecf983b1d` in `/root/ulak/cron/jobs.json`)
- Manual sync can be triggered with: `bash ~/.hermes/scripts/ulak_sync.sh`
- After making changes to Hermes memories, wait for the next sync or trigger manually before running the Agentic OS aggregator.

## Verification
To verify the sync worked correctly:
```bash
# Check that files exist in the snapshot
ls -la /root/ulak/memories/

# Compare with source (if needed)
diff -u ~/.hermes/memories/MEMORY.md /root/ulak/memories/MEMORY.md
```