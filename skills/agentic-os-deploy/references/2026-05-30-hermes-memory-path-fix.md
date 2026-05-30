# 2026-05-30 — Hermes Memory Path Fix & Multi-Source Sync

## Problem

The aggregator's `hermesMemDirs` in `scripts/aggregate.ts` listed `/root/.hermes/memory` (singular) but the actual directory is `/root/.hermes/memories` (plural). The comment above the code even said `~/.hermes/memories` but the code didn't match. This meant Hermes agent memories were silently not being scanned from that source.

Additionally, the cron job's memory sync step only copied from `/root/ulak/memories/` into `/tmp/hermes-memory/` without collision-avoidance naming, risking duplicates when both sources contain identically-named files.

## Fix Applied

1. **Code patch** (`scripts/aggregate.ts` line ~1470): Added `/root/.hermes/memories` (plural) to `hermesMemDirs`:
   ```typescript
   const hermesMemDirs = [
     "/root/ulak/memories",
     "/root/.hermes/memories",   // ← added
     "/root/.hermes/memory",     // still listed (harmless, dir doesn't exist)
     "/tmp/hermes-memory",
   ];
   ```

2. **Sync procedure**: Updated the memory sync step to copy from BOTH sources with prefixed filenames:
   - `/root/ulak/memories/*.md` → `ulak-*.md`
   - `/root/.hermes/memories/*.md` → `hermes-*.md`
   
   This avoids collisions and ensures both sources appear as distinct nodes in the memory graph.

## Verification

After fix: aggregator reports `memory: 20 files / 2 workspaces / 14 events` — hermes workspace now appears correctly.

## bun PATH Note

`bun` is at `/root/.bun/bin/bun` — not on default `$PATH` for cron/background contexts. Always use:
```bash
export PATH="/root/.bun/bin:$PATH"
```
or call `/root/.bun/bin/bun` directly. This applies to ALL pipeline steps (aggregate, build, deploy).
