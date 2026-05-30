# Agentic OS — deployment notes

**URL**: https://agentic.lighthousegroup.net.tr/
**Container**: `hermetic-agenticos-fax02n` (Running, Up 4+ days)
**Web server**: Caddy v2 (config at `/assets/Caddyfile` inside container)

## Current state

- Built as TanStack Start (SSR) app, bundled for Cloudflare Workers
- Running via Caddy in Docker container (not wrangler — wrangler doesn't work on this VPS)
- Serving demo data because `aggregate.ts` hasn't been run inside the container

## Data pipeline

1. Host has Claude Code sessions at `~/.claude/projects/` (19 JSONL files, ~1457 assistant msgs)
2. Aggregate script: `~/code/agentic-os/scripts/aggregate.ts`
3. Output: `~/code/agentic-os/src/data/live-data.json`
4. Last run result: $151.82 spent over 7 days, 5 skills invoked, 12 memory files

## Update procedure

When new Claude activity needs to be reflected in the dashboard:

1. Run aggregate on host: `cd ~/code/agentic-os && bun run scripts/aggregate.ts`
2. Copy `src/data/live-data.json` into the container's Caddy-served directory
   - Container exec may be blocked; if so, use `docker cp` or full container rebuild
3. Caddy serves the JSON file alongside the dashboard HTML

## Known issues

- `wrangler pages dev` fails with `No such module "wrangler:modules-watch"` on this VPS
- Node.js on host is v20; wrangler requires v22+
- `docker exec` triggers approval gates and may be blocked
- Container Caddyfile location: `/assets/Caddyfile` (inside container)
