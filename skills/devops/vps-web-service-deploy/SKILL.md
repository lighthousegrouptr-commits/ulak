---
name: vps-web-service-deploy
description: Deploy and manage web services on the Lighthousegroup VPS (Ubuntu, Docker + Traefik + Dokploy). Covers Docker container creation, Traefik reverse proxy labels, Caddy static file serving, Cloudflare Workers/TanStack Start gotchas, and nginx fallbacks.
version: 1.0.0
platforms: [linux]
metadata:
  hermes:
    tags: [vps, docker, traefik, caddy, deploy, reverse-proxy]
---

# VPS Web Service Deploy

> Target: Lighthousegroup Ubuntu VPS. Docker-based reverse proxy stack (Traefik via Dokploy), with Caddy or containerized apps for individual services.

## Service discovery first

Before deploying anything, **always check if the service already exists**:

```bash
# Check running containers
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"

# Check specific service
curl -s -o /dev/null -w "%{http_code}" https://<service>.lighthousegroup.net.tr/

# Check container inspect for entrypoint/cmds
docker inspect <container> --format '{{json .Config.Labels}}'
docker port <container>
```

Do NOT assume a fresh deploy is needed — the app may already be running in a container with its own web server (Caddy, nginx, etc.).

## VPS architecture

- **Traefik** (`dokploy-traefik` container) — entry point on :80/:443, reverse-proxies to containers
- **Docker** — all services run in containers
- **Host paths** — `/opt/` for persistent data, `/root/code/` for git repos
- **Host tools** — `bun`, `node`, `nginx` may or may not be installed; prefer containerized runtimes

## Docker exec access

`docker exec` into containers may be **blocked by tool policy** (approval gate). When exec is blocked:

1. Ask the user to run commands manually inside the container
2. Use `docker cp` to copy files in/out (may also be blocked)
3. Rebuild the container image with the new content via Dockerfile + `docker build`

## Traefik label-based routing

Containers are exposed via Docker labels (not nginx config on host):

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.myapp.rule=Host(`myapp.lighthousegroup.net.tr`)"
  - "traefik.http.routers.myapp.entrypoints=websecure"
  - "traefik.http.routers.myapp.tls.certresolver=letsencrypt"
  - "traefik.http.services.myapp.loadbalancer.server.port=8080"
```

## Caddy in container

Some apps (e.g. `hermetic-agenticos-*`) run **Caddy** as their web server, not nginx. Caddy config is typically at `/assets/Caddyfile` inside the container.

If exec is blocked, use `docker cp` to extract the Caddyfile:
```bash
docker cp <container>:/assets/Caddyfile /tmp/Caddyfile
```

## Cloudflare Workers / TanStack Start gotcha

**Do not attempt `wrangler pages dev` on this VPS.** The container environment lacks `wrangler:modules-watch` and similar Cloudflare internal modules. `wrangler pages dev` will fail with:

```
Error: No such module "wrangler:modules-watch"
```

Node version may also be too old for current wrangler (needs v22+, VPS has v20).

**Workarounds:**
1. **Dockerize the app** — build a Docker image with the app + a static file server (Caddy, nginx, or `serve`) and deploy as a container
2. **Use nginx on the host** — copy built assets to an nginx-served directory (requires sudo for nginx config)
3. **Use `bun run dev`** — for Bun-native apps, the dev server works fine in a container

## Static SPA fallback (no SSR)

If the app is a pure SPA (no SSR requirement):

1. Build: `bun run build` (produces `dist/client/` with JS/CSS/assets)
2. Write a minimal Dockerfile:
```dockerfile
FROM caddy:2-alpine
COPY dist/client /usr/share/caddy
COPY Caddyfile /etc/caddy/Caddyfile
```
3. Caddyfile:
```
:80 {
    root * /usr/share/caddy
    file_server
    try_files {path} /index.html
}
```
4. Build + run with Traefik labels for automatic HTTPS

## nginx on host (fallback)

The host has nginx at `/etc/nginx/`. Sites go in `/etc/nginx/sites-enabled/`. **Requires sudo** — will trigger approval gates.

## Pitfalls

- **Port conflicts**: VPS ports 80/443 are claimed by Traefik. Use Traefik labels, not host port mapping.
- **wrangler:modules-watch**: Never try to run `wrangler pages dev` locally on this VPS. Dockerize instead.
- **docker exec blocked**: Plan for file transfer via rebuild or ask user.
- **Node version**: Host Node is v20. wrangler needs v22+. Use `node-v22` binary from `/tmp/` if needed, or Dockerize.
- **Data persistence**: Container restarts lose filesystem changes. Use Docker volumes or bind mounts.
- **SPA + API endpoints**: TanStack Start / Vite SPAs that fetch data via `/__api` endpoints at runtime need those endpoints provided in production. The Vite `configureServer` plugin only works in dev — in production, your start command MUST serve the same endpoints (or proxy to them). Check `src/lib/use-*.ts` hooks to discover which endpoints the app expects.
- **Git push access**: `lighthousegrouptr-commits` SSH key may not have push access to all repos. If push fails with Permission denied, either (a) add the key as a contributor to the repo, or (b) use HTTPS with a PAT.
- **Project identity confusion**: Multiple projects coexist on this VPS (`musikapp`, `agentic-os`, etc.). Each has its own repo, container, and Dokploy service. **Always confirm which project the user means before touching repos, containers, or configs.** When the user says "my repo" without naming it, ask. Don't assume — musikapp ≠ agentic-os ≠ ulak, all managed by `lighthousegrouptr-commits` but repos live under different GitHub accounts.

## Dokploy uses Docker Swarm

Dokploy creates **Swarm services**, not standalone containers. Key implications:

- Service discovery: `docker service ls | grep <name>`
- Service inspect: `docker service inspect <name>`
- **Add volume mounts**: `docker service update --mount-add type=bind,source=/host/path,target=/container/path,readonly=true <service>`
- Mounts take effect only after the service converges (container is recreated)
- Old containers from previous versions may linger — `docker ps | grep <name>` to find the active one
- Swarm containers are named `<service>.<replica>.<id>` (e.g. `hermetic-agenticos-fax02n.1.abc123`)

## Nixpacks build (Dokploy default)

When Dokploy uses Nixpacks (the default), it auto-generates a **Caddyfile** inside the container at `/assets/Caddyfile`. This Caddyfile uses Railway-style syntax like `{$PORT:3000}`.

- The Caddyfile is **not** in the repo — it's generated by Nixpacks at build time
- To customize: either switch to Dockerfile build type, or overwrite `/assets/Caddyfile` in the container and `caddy reload`
- Nixpacks sets env vars like `NIXPACKS_SPA_OUTPUT_DIR=dist/client`

## Overwriting Caddyfile in container

Use `docker exec <container> tee /assets/Caddyfile << 'EOF' ... EOF` (heredoc with single-quoted EOF prevents shell expansion).

After writing the new Caddyfile, reload Caddy:
```bash
docker exec <container> caddy reload --config /assets/Caddyfile --adapter caddyfile
```

**Caddyfile syntax**: Caddy v2 on this VPS. Use `:3000` (not `{$PORT:3000}` from the Nixpacks original — that was Railway template syntax that still works in Caddy). Use absolute paths (`/app/dist/client`, not `../app/dist/client`).

## Runtime data aggregation (Vite + static output)

When a Vite app generates a data file at runtime (e.g. `bun run scripts/aggregate.ts` scanning `~/.claude/`) and the frontend fetches it from a `/__live-data` endpoint:

1. **Dev mode**: Vite `configureServer` plugin serves `/__live-data` middleware — this works fine
2. **Production**: That middleware is gone. Caddy serves static files only.
3. **Solutions** (pick one):
   - **Bundle at build time**: Use `import data from '@/data/live-data.json'` instead of `fetch('/__live-data')` — then aggregate runs before `vite build` and data is baked into the bundle. Requires rebuild on data change.
   - **Serve from Caddy**: Add `handle_path /__live-data { root * /app/src/data; rewrite * /live-data.json }` to Caddyfile, mount `~/.claude` as a volume, and run aggregate in the start command or via cron.
   - **Custom start script**: Replace Caddy with a Bun server that handles both `/__live-data` and static files.

The build-time bundle approach (option 1) is the most reliable for Dokploy: aggregate runs during `bun run build`, data is baked in, no runtime dependencies.
