# Cron Run 8 — 2026-05-31 (Full Refresh with Claude Project Memory Sync)

## What changed
This run's cron job description explicitly requested copying `~/.claude/projects/*/memory/*.md` files into `/tmp/hermes-memory/` with `claude-project-<label>-` prefixed names, in addition to the usual hermes/ulak sync.

## Memory sync step (new pattern)
```python
# Copied from ~/.claude/projects/*/memory with prefixed names
# Label derived from project dir name (stripped leading '-')
# e.g., ~/.claude/projects/-root/memory/agentic-os.md → claude-project-root-agentic-os.md
```

## Results
- **Total files in `/tmp/hermes-memory/`**: 16 (4 hermes/ulak + 12 claude-project-root-*)
- **Aggregator output**: `32 files / 2 workspaces / 14 events`
  - Previous runs were ~18-22 files. The jump to 32 is from:
    - 12 claude-project-root-* files in `/tmp/hermes-memory` (prefixed copies)
    - 13 files from direct `~/.claude/projects/-root/memory/` scan (same files, unprefixed)
    - 4 files from `/root/.hermes/memories/` + `/root/ulak/memories/` (direct scan + `/tmp` copies)
    - Overlap is expected and stable
- **Deploy version**: `2936dec9-5c51-4b41-8766-22121295f443`
- **Errors**: None (all non-blocking warnings as per pitfall #6)

## Lesson
When the cron job description explicitly requests syncing `~/.claude/projects/*/memory` into `/tmp/hermes-memory/` with prefixed names, the file count will be ~32 (not ~18-22). This is the new expected steady state. Do NOT try to "fix" the 32-count — it's consistent and by design.

If the cron description does NOT request this extra sync, expect ~22 files (hermes + claude-project from direct aggregator scans, with `/tmp` containing only hermes/ulak copies).
