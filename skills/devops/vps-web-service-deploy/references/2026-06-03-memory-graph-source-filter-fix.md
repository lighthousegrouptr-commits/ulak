# 2026-06-03: Memory Graph Source Filter Fix

## Problem
The memory page (`/memory`) showed filter buttons for "All - Obsidian - Local Claude" but NOT "Hermes", even though Hermes memory files existed and were being aggregated. The 3D graph workspace nodes for Hermes existed in the data but were invisible in the UI filter.

## Root Cause
`src/routes/memory.tsx` had hardcoded source lists:
```
const BASE_SOURCES = ["obsidian", "claude"] as const;
type SourceId = "obsidian" | "claude" | "pinecone";
```
And the `pills` array in `SourceFilter` component only listed Obsidian and Claude.

## Fix (3 changes in `src/routes/memory.tsx`)

1. **Add "hermes" to `BASE_SOURCES` and `PINECONE_SOURCES`:**
```
const BASE_SOURCES = ["obsidian", "claude", "hermes"] as const;
const PINECONE_SOURCES = ["obsidian", "claude", "hermes", "pinecone"] as const;
```

2. **Add "hermes" to `SourceId` type:**
```
type SourceId = "obsidian" | "claude" | "hermes" | "pinecone";
```

3. **Add Hermes pill to `SourceFilter` component:**
```
{
  id: "hermes",
  label: "Hermes",
  color: "#f59e0b",
  tooltip: "Hermes agent memory (Ulak)",
},
```

## Result
Memory page now shows: **All - Obsidian - Local Claude - Hermes** filter buttons. Hermes workspace nodes are visible in the 3D graph when the Hermes filter is active.

## Files Modified
- `src/routes/memory.tsx` — 3 patches (BASE_SOURCES, SourceId type, SourceFilter pills)

## Related
- Aggregate memory path fix: `references/2026-06-03-aggregate-memory-path-fix.md`
- Aggregate skills path fix: `references/2026-06-03-aggregate-skills-path-fix.md`
