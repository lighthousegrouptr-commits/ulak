# Agentic OS Configuration Reference

## Aggregate Memory Paths

The aggregate script (`scripts/aggregate.ts`) scans these paths for memory files:

| Path | Source | Notes |
|------|--------|-------|
| `~/.claude/projects/*/memory/` | Claude | Per-project memory dirs |
| `~/Obsidian/`, `~/Documents/Obsidian/` | Obsidian | macOS-only paths (Linux: not present) |
| `/root/ulak/memories/` | Ulak/Hermes | **Added 2026-06-03** - Hermes memory snapshot, synced every 30 min |

### Adding a new memory path

In `scripts/aggregate.ts`, inside `parseMemory()`, add before the "Claude project memory dirs" section:

```typescript
// Custom memory dir
const customMemDir = join(HOME, "your", "path");
if (existsSync(customMemDir)) {
  sources.push({ root: customMemDir, label: "your-label" });
}
```

## KV Namespace

| Binding | ID | Purpose |
|---------|-----|---------|
| `LIVE_DATA` | `df2bda58d7bb4abe91569c4c48c5bf5b` | Live dashboard data |

## Cloudflare Zone

| Zone | ID |
|------|-----|
| `lighthousegroup.net.tr` | `6d59ce28d0fc5cdb1a71b401d7e5f366` |

## Worker

| Name | Route | Main |
|------|-------|------|
| `tanstack-start-app` | `agentic.lighthousegroup.net.tr/*` | `dist/server/index.js` (via Vite build) |
