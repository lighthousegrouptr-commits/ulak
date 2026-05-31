# Supplementary Notes — 2026-05-31 Deploy

## `/root/.hermes/memories/` may be absent

On the 2026-05-31 run, `/root/.hermes/memories/` did not contain files. The only active memory source was `/root/ulak/memories/` (the ulak git snapshot). The `hermesMemDirs` array in aggregate.ts lists both paths — this is fine; the `existsSync()` guard handles missing dirs gracefully.

**Implication for cron scripts**: When syncing to `/tmp/hermes-memory/`, always use the `for f in ...*.md; do [ -f "$f" ] && cp ...` pattern (not bare `cp *.md`) — empty globs fail silently in bash without `shopt -s nullglob` or a file-existence check.

## Skills count after aggregator

The aggregator reported "9 installed" skills on this run. This counts subdirectories with `SKILL.md` in both `~/.claude/skills/` and `/root/.hermes/skills/`. If you add new skill directories, re-run the aggregator and verify the count in the output before deploying.

## Value extracted (7d)

`$151.82` — total Claude Code usage cost for the trailing 7 days, per the aggregate.
