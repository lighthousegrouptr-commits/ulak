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
