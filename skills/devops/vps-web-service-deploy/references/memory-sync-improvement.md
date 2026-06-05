# Memory Sync Improvement - Agentic OS Deploy Pipeline

## Problem Identified
In the Agentic OS deployment pipeline, the memory sync step was using flat file copies that caused naming collisions:
- Multiple sources (hermes, ulak) copying files with same names (MEMORY.md, USER.md)
- Last writer wins, causing data loss from earlier sources
- No clear separation between different memory sources

## Solution Implemented
Changed to subdirectory-based copy approach that completely avoids collisions:
```bash
mkdir -p /tmp/hermes-memory/hermes /tmp/hermes-memory/ulak
cp ~/.hermes/memories/*.md /tmp/hermes-memory/hermes/
cp /root/ulak/memories/*.md /tmp/hermes-memory/ulak/
```

## Benefits
1. **Zero data loss**: Each source maintains its own files
2. **Clear source attribution**: Files are organized by source directory
3. **Backward compatibility**: Aggregator already scans all subdirectories recursively
4. **Cron-safe**: Works in environments where `rm` is blocked
5. **Extensible**: Easy to add more memory sources later

## Aggregator Behavior
The aggregate.ts script already walks directories recursively via `walkMd()` function, so it automatically picks up files in:
- `/tmp/hermes-memory/hermes/`
- `/tmp/hermes-memory/ulak/`
- Any other subdirectories added later

No changes needed to the aggregator - it naturally handles the new structure.

## Usage in Deploy Pipeline
This approach is now the **recommended** method documented in the vps-web-service-deploy skill for Step 1 of the Agentic OS full refresh pipeline.