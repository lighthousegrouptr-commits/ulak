# Agentic OS — deployment notes

**URL**: https://agentic.lighthousegroup.net.tr/
**Repo**: `sasdsamatt123/agentic-os` (GitHub), `lighthousegrouptr-commits` SSH key lacks push access — use HTTPS token or add collaborator

## Architecture (key insight)

`useLiveData` hook fetches `/__live-data` endpoint at runtime (NOT a static import).
The Vite dev server provides this via a `configureServer` plugin — in production you MUST
provide your own endpoint that reads `src/data/live-data.json` from disk and serves it as JSON.

Same for `/__refresh_data` (POST) — triggers a re-run of the aggregator.

## Files added

- `Dockerfile` — multi-stage: build with bun, runtime serves static + API endpoints
- `nixpacks.toml` — alternative build config (build runs aggregate before vite build)
- `scripts/docker-start.sh` — runtime: re-run aggregator, then Bun static server with:
  - `GET /__live-data` → serves `src/data/live-data.json` (or example fallback)
  - `POST /__refresh_data` → re-runs `bun run scripts/aggregate.ts`
  - Static file serve from `dist/client/` with SPA fallback to `index.html`

## Deployment steps

1. Push Dockerfile+nixpacks.toml to repo (GitHub — see access note above)
2. In Dokploy: set Build Type to Dockerfile (or Nixpacks)
3. Add volume mount: `/root/.claude:/root/.claude:ro` (read-only, so container can read Claude sessions)
4. Rebuild

## Known issues

- `wrangler pages dev` fails with `No such module "wrangler:modules-watch"` on this VPS
- Node.js on host is v20; wrangler requires v22+
- `docker exec` triggers approval gates and may be blocked
- `sasdsamatt123/agentic-os` repo: `lighthousegrouptr-commits` SSH key has no push access (Permission denied)
