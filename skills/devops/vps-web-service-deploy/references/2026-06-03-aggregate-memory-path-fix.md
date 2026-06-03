# 2026-06-03: Aggregate Memory Path Fix

## Problem

Memory file count dropped from 18 to 12 after aggregate run. The aggregate script was only scanning:
- `~/.claude/projects/*/memory/` (12 files found)
- Obsidian vaults (macOS-only paths, not present on Linux)

Missing: `/root/ulak/memories/` (2 files: USER.md, MEMORY.md)

## Root Cause

The aggregate script's `parseMemory()` function did not include the Hermes/Ulak memory path at `/root/ulak/memories/`.

## Fix Applied

In `scripts/aggregate.ts`, inside `parseMemory()`, added before the "Claude project memory dirs" section:

```typescript
// Hermes/Ulak memory dir
const ulakMemDir = join(HOME, "ulak", "memories");
if (existsSync(ulakMemDir)) {
  sources.push({ root: ulakMemDir, label: "ulak" });
}
```

## Result

After fix: 14 memory files (12 Claude + 2 Ulak), 2 workspaces.

## Note

The user reported 18 files. The remaining 4 files may be in a different path not yet identified. When the user provides the exact path, add it to the same section in `parseMemory()`.
