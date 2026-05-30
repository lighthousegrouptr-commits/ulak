# Hermes Memory Integration — Reference

## Verified Source Paths (May 2026)

| Path | Exists? | Contents | Notes |
|------|---------|----------|-------|
| `/root/ulak/memories/` | Yes | MEMORY.md, USER.md | Synced from `~/.hermes/` every 30 min via `ulak_sync.sh`. **Use this as the primary source.** |
| `/tmp/hermes-memory/` | If created | MEMORY.md, USER.md | Ephemeral staging dir. Created by the deploy pipeline. |
| `~/.hermes/memory/` | No | — | Does not exist on this system (verified May 2026). |
| `~/.hermes/memories/` | No | — | Does not exist on this system (verified May 2026). |
| `/root/ulak/memory/` | No | — | Singular form doesn't exist. Use `/root/ulak/memories/` (plural). |

## Sync Step

```bash
mkdir -p /tmp/hermes-memory
cp ~/.hermes/memories/MEMORY.md ~/.hermes/memories/USER.md /tmp/hermes-memory/
```

Skip .lock files (they're empty anyway).

## Aggregate.ts Built-in Hermes Support

The aggregator (`scripts/aggregate.ts`, function `parseMemory()`) already includes these paths in the `hermesMemDirs` array (around line 1460):

```typescript
const hermesMemDirs = [
  "/tmp/hermes-memory",
  "/root/ulak/memories",
  "/root/.hermes/memory",
];
```

**No code patch is required** unless `parseMemory()` is rewritten from scratch. If rewriting, add the same block before the `// Aggregate` comment.

## Verification

After running `bun run scripts/aggregate.ts`:
- Log output includes `hermes` workspace
- `src/data/live-data.json` contains a `hermes`-labeled workspace node
- File count should include 2 Hermes files (MEMORY.md, USER.md)

**PATH reminder**: `bun` is not on the default PATH. Always use:
```bash
export PATH="$PATH:/root/.bun/bin"
```
