# Agentic OS — Production Setup

## Repo
- GitHub: `lighthousegrouptr-commits/agentic-os`
- VPS: `187.77.79.159` (Dokploy)
- Domain: `agentic.lighthousegroup.net.tr`

## Cron Jobs
- `2655c3b31f43` — every 30min: sync Hermes memory + aggregate + build + wrangler deploy
- `925ecf983b1d` — Ulak GitHub sync

## Key Files
- `nixpacks.toml` — build phase only, no [start]
- `.nixpacks/Caddyfile` — Caddyfile override
- `wrangler.jsonc` — Worker config (main: src/server.ts)
- `src/data/live-data.json` — committed, real data (1457+ msgs)
- `src/lib/use-live-data.ts` — static import prod, fetch dev
- `scripts/cron-agentic-deploy.sh` — local cron script
- `scripts/refresh-data.sh` — VPS container-only refresh

## Hermes Memory Sync
- Source: `/root/ulak/memory/` (on Hermes server, NOT on VPS)
- Target: VPS container `/app/src/data/live-data.json`
- Aggregate reads: `~/.claude/` + `~/memory/` dirs
