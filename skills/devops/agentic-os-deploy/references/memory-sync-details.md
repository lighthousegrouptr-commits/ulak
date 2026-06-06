# Memory Sync Details for Agentic OS Deployment

This document details the memory synchronization process used in the agentic-os-deploy skill.

## Memory Sources

The Agentic OS dashboard aggregates data from two primary sources:
1. ~/.claude/ - Claude Code native data (projects, settings, etc.)
2. Hermes agent memories - Synced from the user's Hermes agent

## Sync Process

During deployment, memories are synchronized from two potential locations:
- `/root/ulak/memories/` - A git-synced snapshot of Hermes memories (updated every 30 minutes via cron)
- `~/.hermes/memories/` - The live Hermes memories on the current machine

The sync process:
1. Creates `/tmp/hermes-memory/` directory
2. Copies contents from `/root/ulak/memories/` (if exists)
3. Copies contents from `~/.hermes/memories/` (if exists), overwriting any duplicates
   - This ensures live memories take precedence over the synced snapshot

## Memory File Structure

Both locations should contain:
- `MEMORY.md` - Agent's persistent memory/notes
- `USER.md` - User profile information

## Aggregator Integration

The aggregator script (`scripts/aggregate.ts`) is configured to scan:
- `~/.claude/projects` and `~/.claude/memory` (standard Claude Code locations)
- `/tmp/hermes-memory/` (the synced Hermes memories)

This allows the dashboard to display unified insights from both the user's Claude Code usage and their Hermes agent interactions.

## Notes

- The aggregator intentionally skips macOS-specific signals (like Keychain credentials) when running on Linux
- Memory files are typically small text files containing markdown-formatted notes
- If neither memory source exists, the aggregator will still run but show 0 memory files