# Agentic OS — deployment notes

**URL**: https://agentic.lighthousegroup.net.tr/
**Repo**: `sasdsamatt123/agentic-os` (GitHub)
**Swarm service**: `hermetic-agenticos-fax02n`
**Traefik config**: `/etc/dokploy/traefik/dynamic/hermetic-agenticos-fax02n.yml` (routes to `http://hermetic-agenticos-fax02n:3000`)

## Git access

`lighthousegrouptr-commits` SSH key lacks push access to `sasdsamatt123/agentic-os`.
Options: (a) add `lighthousegrouptr-commits` as collaborator on GitHub, (b) use HTTPS with PAT.

Also check `~/.ssh/` — `~/.ssh/config` may map `github.com` to a specific key (`IdentityFile`). Two keys exist (`id_ed25519`, `musikapp`), both currently tied to `lighthousegrouptr-commits`.

## Architecture (key insight)

`useLiveData` hook fetches `/__live-data` endpoint at runtime (NOT a static import).
The Vite dev server provides this via a `configureServer` plugin — in production you MUST
provide your own endpoint that reads `src/data/live-data.json` from disk and serves it as JSON.

Same for `/__refresh_data` (POST) — triggers a re-run of the aggregator.

## Nixpacks vs Dockerfile

Dokploy uses **Nixpacks** by default, which auto-generates a Caddyfile at `/assets/Caddyfile`.
The Caddyfile uses Railway-style `{$PORT:3000}` syntax (inherited from Railway template heritage).

Alternative: switch to **DockerType** build — provide a `Dockerfile` + `scripts/docker-start.sh`.
The nixpacks.toml build file runs `bun run scripts/aggregate.ts` before `bun run build`,
which bakes data into the bundle at build time (simplest approach for data that changes on deploy).

## Swarm service operations

```bash
# Add volume mount
docker service update --mount-add type=bind,source=/root/.claude,target=/root/.claude,readonly=true <service>

# Check service converged
docker service inspect <service> --format '{{json .UpdateStatus}}'

# Find active container
docker ps | grep <service>
```

## Caddyfile manipulation

Nixpacks-generated Caddyfile can be overwritten inside the container:

```bash
# Write new Caddyfile (single-quoted heredoc prevents shell expansion)
docker exec <container> tee /assets/Caddyfile << 'EOF'
{
    admin off
    ...
}
:3000 {
    handle_path /__live-data {
        root * /app/src/data
        file_server { hide .* }
        rewrite * /live-data.json
    }
    ...
}
EOF

# Reload Caddy (no restart needed)
docker exec <container> caddy reload --config /assets/Caddyfile --adapter caddyfile
```

Use absolute paths (`/app/dist/client` not `../app/dist/client`).
Caddy v2.8.4 on VPS — `:3000` (not Railway-style `{$PORT:3000}`).

## Files added

- `Dockerfile` — multi-stage: build with bun, runtime serves static + API endpoints
- `nixpacks.toml` — alternative build config (build runs aggregate before vite build)
- `scripts/docker-start.sh` — runtime: re-run aggregator, then Bun static server with:
  - `GET /__live-data` → serves `src/data/live-data.json` (or example fallback)
  - `POST /__refresh_data` → re-runs `bun run scripts/aggregate.ts`
  - Static file serve from `dist/client/` with SPA fallback to `index.html`

## Known issues

- `wrangler pages dev` fails with `No such module "wrangler:modules-watch"` on this VPS
- Node.js on host is v20; wrangler requires v22+
- Caddyfile rewrite + reload was attempted but EOF error persisted — may need different approach
- Aggregate data was successfully generated inside container (1458 assistant msgs, 12 memory files, 5 skills, $151.82) but frontend still showed DEMO DATA because the bundle had stale data
