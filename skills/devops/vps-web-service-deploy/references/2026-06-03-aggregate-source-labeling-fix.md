# 2026-06-03: Aggregate Source Labeling Fix

## Problem
Memory graph showed Hermes workspace files under "Obsidian" source. The filter buttons showed "All - Obsidian - Local Claude" but NOT "Hermes". Even though Hermes memory paths were being scanned and files were indexed, the source label was wrong.

## Root Cause
In `scripts/aggregate.ts`, the `parseMemoryFolder` function determined `wsSource` (workspace source) only by checking for `claude-` prefix in the workspace ID. All other workspaces defaulted to `"obsidian"`:

```typescript
// BEFORE (buggy):
const wsSource = workspaceId.startsWith("claude-") ? "claude" : "obsidian";
```

This meant Hermes workspaces (e.g., workspace ID "hermes" or "ulak") were labeled as "obsidian".

Similarly, file-level `source` in `fileNodes` was derived from the workspace source, so all Hermes files appeared as "obsidian" in the graph.

## Fix
Added explicit source mapping for Hermes/Ulak workspaces:

```typescript
// AFTER (fixed):
let wsSource = "obsidian";
if (workspaceId.startsWith("claude-")) wsSource = "claude";
else if (workspaceId === "hermes" || workspaceId === "ulak" || workspaceId.startsWith("hermes-") || workspaceId.startsWith("ulak-")) wsSource = "hermes";
```

Applied in both:
1. `parseMemoryFolder` - workspace source assignment (~line 1513)
2. `fileNodes` creation - file source assignment (~line 1688)

## Result
- Memory graph now correctly shows Hermes as a separate source
- Filter buttons: **All - Obsidian - Local Claude - Hermes**
- Hermes workspace nodes are properly colored and filterable

## Related
- Memory graph UI filter fix: `references/2026-06-03-memory-graph-source-filter-fix.md`
- Aggregate memory path fix: `references/2026-06-03-aggregate-memory-path-fix.md`
