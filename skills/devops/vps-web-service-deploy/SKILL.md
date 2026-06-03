---
name: vps-web-service-deploy
description: Deploy and manage web services on the Lighthousegroup VPS (Ubuntu, Docker + Traefik + Dokploy). Covers Docker container creation, Traefik reverse proxy labels, Caddy static file serving, Cloudflare Workers/TanStack Start gotchas, nginx fallbacks, TanStack Start SSR apps (Agentic OS), Hermes memory/skills integration, and full refresh deployment pipelines.
version: 1.7.9
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

## Bun installation + PATH gotcha

**`bun` may not be installed at all on this VPS.** Check first:
```bash
which bun || echo "NOT FOUND"
```

If missing, install via npm (the security scanner blocks `curl | bash`):
```bash
npm install -g bun    # installs to /usr/local/bin/bun
```

After npm install, bun is at `/usr/local/bin/bun` (on PATH). If installed via the official
installer (`curl | bash` — blocked on this VPS), it goes to `/root/.bun/bin/bun` (NOT on PATH).

**Two known bun locations on this VPS:**
| Method | Path | On PATH? |
|---|---|---|
| `npm install -g bun` | `/usr/local/bin/bun` | ✅ Yes |
| `curl | bash` (blocked) | `/root/.bun/bin/bun` | ❌ No |

Use `which bun` to determine which, then either use bare `bun` or full path as needed.
This affects `bun run scripts/aggregate.ts`, `bun run build`, `bun run dev`, etc.

## Environment variables for deploy tools

Several API tokens and keys are stored in `/root/.profile` and are NOT automatically available
in non-interactive shell sessions (cron jobs, agent sessions). Before running deploy commands,
source the profile:

```bash
source /root/.profile 2>/dev/null
```

Key environment variables available after sourcing:
- `CLOUDFLARE_API_TOKEN` — required by `wrangler deploy` in non-interactive environments
- `ANTHROPIC_API_KEY` — Claude API access

**Always source `/root/.profile` before `wrangler deploy`.** Without `CLOUDFLARE_API_TOKEN`, wrangler fails with:
```
ERROR: In a non-interactive environment, it's necessary to set a CLOUDFLARE_API_TOKEN
environment variable for wrangler to work.
```

## Terminal tool loop protection

The terminal tool has a **same-tool-failure guard**: if the same tool fails 3 times in one turn, a warning fires and you must diagnose before retrying. On this VPS, this commonly happens with `bun` commands because `bun` is not on `$PATH`.

**Pattern to avoid:**
```
terminal("bun run build")           # fails: bun not found
terminal("which bun")               # fails: not on PATH
terminal("bun run build")           # fails again → triggers loop warning
```

**Fix:** Always use the absolute path or export PATH in the same command:
```bash
export PATH="/root/.bun/bin:$PATH" && bun run build
# or
/root/.bun/bin/bun run build
```

This applies to ALL `bun` invocations: `bun run scripts/aggregate.ts`, `bun run build`, `bun run dev`, `bun install`, etc.

## wrangler version tracking

| Run | wrangler version | update available |
|---|---|---|
| r46 | v4.86.0 | — |
| r45 | v4.90.0 | v4.97.0 |
| r44 | v4.86.0 | v4.97.0 |
| r43 | v4.86.0 | v4.97.0 |
| r42 | v4.86.0 | v4.97.0 |
| r41 | v4.86.0 | — |
| r40 | v4.86.0 | — |
| r38 | v4.86.0 | v4.96.0 |
| r37 | v4.86.0 | v4.96.0 |
| r36 | v4.86.0 | v4.96.0 |
| r35 | v4.90.0 | — |
| r34 | v4.90.0 | — |
| r33 | v4.86.0 | — |
| r32 | v4.86.0 | — |
| r31 | v4.86.0 | — |
| r30 | v4.86.0 | v4.96.0 |
| r27 | v4.86.0 | v4.96.0 |
| r22 | v4.90.0 | — |
| r21 | v4.90.0 | — |
| r20 | v4.86.0 | v4.96.0 |
| r16 | v4.90.0 | v4.95.0 |

**Bare `wrangler deploy` confirmed working** at r33, r36, r37, r38, r39, r44, r45, r46 (wrangler v4.86.0–v4.90.0).

**⚠️ agentic-os deploy command (UPDATED 2026-06-03 run r46):**
```bash
cd /root/code/agentic-os
export PATH="/root/.bun/bin:$PATH"
bun run build
wrangler deploy
```

**Bare `wrangler deploy` is the correct command.** When both `wrangler.jsonc` (project root) and `.wrangler/deploy/config.json` exist, wrangler prints a "Using redirected Wrangler configuration" notice and automatically uses the deployed config (`dist/server/wrangler.json`). This is **non-fatal** — the deploy proceeds normally. The `--config dist/server/wrangler.json` flag from r43 notes was unnecessary.

**`CLOUDFLARE_API_TOKEN` check:** In interactive sessions and most cron runs, the token is already in the inherited environment and `wrangler deploy` works without sourcing. If deploy fails with a token error, source the profile:
```bash
source /root/.profile 2>/dev/null
```

- Auth: `lighthousegrouptr@gmail.com` (stored in `~/.wrangler/`)
- Deploy is immediate — new version goes live globally within ~30s
- No Cloudflare cache purge needed for Worker deploys

## Docker exec access

`docker exec` into containers is **frequently blocked by tool policy** (approval gate). Plan for this:

1. **Minimize `docker exec` calls** — prefer `docker cp` for file transfer, `docker restart` for reloads
2. **Batch commands** — combine multiple operations into single `docker exec` to reduce approval requests
3. **Use `docker logs`** to diagnose instead of exec when possible
4. **When exec is blocked**: Ask the user to run the command manually, or use alternative approaches

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

## Cloudflare Workers — static SPA deployment

**`env.ASSETS` does NOT work on Cloudflare Workers** (only on Pages). Do not use the `env.ASSETS.fetch()` pattern — it silently returns 404.

**For static SPAs, use one of these approaches:**

1. **Cloudflare Pages** (preferred): `wrangler pages deploy dist/client --project-name=<name>`
2. **Docker + Caddy container** (most reliable for heavy JS SPAs): Build `dist/client/` into a Caddy image with `try_files {path} /index.html`
3. **Inline HTML Worker** (single-file dashboards only): Bake HTML into Worker as string via build script

See `references/tanstack-start-1167-server-entry-removed.md` for full details and templates.

## Cloudflare Workers / TanStack Start gotcha

**Do not attempt `wrangler pages dev` on this VPS.** The container environment lacks `wrangler:modules-watch` and similar Cloudflare internal modules.

**Workarounds:**
1. **Dockerize the app** — build a Docker image with the app + a static file server (Caddy, nginx, or `serve`) and deploy as a container
2. **Static SPA Worker** — use `env.ASSETS` pattern (recommended for agentic-os and similar SPAs)

## Static SPA fallback (no SSR) — Docker approach

If deploying via Docker/Worker instead of Cloudflare Worker:

1. Build: `bun run build` (produces `dist/client/` with JS/CSS/assets)
2. Dockerfile:
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

- **Cron task source path typo**: Cron task instructions frequently specify `/root/ulak/memory/` (singular). The correct source is `/root/ulak/memories/` (plural). Similarly, `/root/.hermes/memory/` does NOT exist — use `/root/.hermes/memories/`.

- **Decision fatigue**: Levent struggles when offered multiple options. For config/deploy decisions: decide yourself, state the choice and rationale in one sentence, move on. Don't present option menus.

- **TanStack Start SSR is broken** (v1.167+): `@tanstack/react-start/server-entry` was removed. Vite plugin silently produces "placeholder" handler. Use static SPA Worker pattern instead. See `references/tanstack-start-1167-server-entry-removed.md`.

- **Pipe-to-interpreter blocked**: `cat file | python3 -c "..."` AND `cat file | bun -e "..."` are both blocked by the host security scanner (tirith pattern: `pipe_to_interpreter`). Use `read_file` for direct file access, or `execute_code` with Python `open()` / Bun `Bun.file()` instead. Never pipe shell output into any interpreter (`python3`, `bun`, `node`, `ruby`, etc.).

- **Port conflicts**: VPS ports 80/443 are claimed by Traefik. Use Traefik labels, not host port mapping.
- **wrangler:modules-watch**: Never try to run `wrangler pages dev` locally on this VPS.
- **worker.js HTML embedding**: When baking HTML into a Cloudflare Worker as an inline JS string, `JSON.stringify()` does NOT escape `</script>` or `</style>` tags. These appear literally in the output and the browser's HTML parser treats them as closing tags, breaking the page. **The `<\\/script>` replacement does NOT work** — the HTML parser still recognizes the tag. The correct fix is to serve JS from a separate endpoint (`/__app_js`) via synchronous XHR + `eval()`, keeping `</script>` out of the HTML response entirely. See `references/worker-html-script-escaping.md`.
- **build-worker.mjs path resolution**: The script lives at `scripts/build-worker.mjs` but must resolve paths from the project root. Always use `const projectRoot = resolve(__dirname, "..")` and `resolve(projectRoot, "dist/client/dashboard.html")`.
- **build-worker.mjs must also update `dist/server/wrangler.json`**: The Vite-generated `wrangler.json` does NOT include `kv_namespaces` from `wrangler.jsonc`. The build script must read, patch, and rewrite it after each build, or `wrangler deploy` will succeed but the Worker will have no KV access.
- **`wrangler kv key put` requires `--remote`**: Without the flag, writes go to the local dev KV namespace (in `~/.wrangler/state/`), NOT production. Always use `wrangler kv key put --binding=NS --remote "key" --path file.json`.
- **Sibling subagent file conflicts**: When multiple subagents edit the same file (e.g., `src/worker-template.js`, `scripts/build-worker.mjs`, `package.json`), always re-read the file before writing. The `_warning` field in patch/write_file output signals this — do not ignore it.
- **Hermes memory duplicate nodes**: When multiple Hermes memory paths in the aggregator point to the same physical files (e.g., `/root/.hermes/memories/` and `/tmp/hermes-memory/` containing identical MEMORY.md/USER.md), the memory graph shows duplicate nodes. The aggregator deduplicates by workspace ID but not across workspace sources. **Mitigation**: copy files with source-suffixed names (`MEMORY-ulak.md`, `MEMORY-hermes.md`, `USER-ulak.md`, `USER-hermes.md`) so both sources are preserved distinctly. The ulak versions are more recent (synced every 30 min).

- **`/tmp` file accumulation across cron runs**: In cron sessions, `rm` in `/tmp` triggers "delete in root path" approval gates and fails. Over many runs, `/tmp/hermes-memory/` accumulates stale files (`.lock`, `sync.sh`, old `.md` copies). **This is harmless** — the aggregator only reads `.md` files, and the extra files don't cause errors. Do not waste time trying to clean `/tmp` in cron contexts; only clean up in interactive sessions if needed.

- **`wrangler.jsonc` Vite warning (NEW)**: Since the build migrated to Vite, `bun run build` prints: "your worker config contains configuration options which are ignored since they are not applicable when using Vite: `no_bundle`, `rules`". This is **purely informational** — Vite manages its own bundling and ignores these Cloudflare Worker-specific keys. Do NOT remove them from `wrangler.jsonc` unless you're certain they aren't needed for the deploy step. They are for the pre-Vite Worker pattern and cause no harm being present.

- **`/tmp` deletion blocked by tool policy**: In non-interactive sessions (cron jobs), `rm -rf /tmp/hermes-memory` and `rm -f /tmp/hermes-memory/*` trigger "delete in root path" approval gates and fail. **Workaround**: use `write_file` to directly overwrite each target file with fresh content — read source files with `read_file`, then write to `/tmp/hermes-memory/`. `write_file` overwrites existing content without needing deletion. Do NOT attempt to clean up stale files (`.lock`, `sync.sh`, old copies) — the aggregator only reads `.md` files and ignores the rest. This is the simplest approach and avoids any deletion or shell scripting.

- **References directory**: Kept pruned to recent runs (r24+) plus structural references. Older run logs (>30 days or >15 versions back) are removed to keep the skill directory manageable. The version log (`references/agentic-os-version-log.md`) retains the full history.
- **Project identity confusion**: Multiple projects coexist on this VPS (`musikapp`, `agentic-os`, etc.). **Always confirm which project the user means before touching repos, containers, or configs.**

## Dokploy uses Docker Swarm

Dokploy creates **Swarm services**, not standalone containers. Key implications:

- Service discovery: `docker service ls | grep <name>`
- **Add volume mounts**: `docker service update --mount-add type=bind,source=/host/path,target=/container/path <service>`
- Swarm containers are named `<service>.<replica>.<id>`
- **No `force-update`**: Use `docker restart <container>` to force a restart.

## Nixpacks build (Dokploy default)

When Dokploy uses Nixpacks (the default), it auto-generates a **Caddyfile** inside the container at `/assets/Caddyfile`.

- The Caddyfile is **not** in the repo — it's generated by Nixpacks at build time
- Nixpacks copies the repo TWICE — the final copy can overwrite build output with stale repo files. Ensure `dist/` is `.gitignore`d.

**For pure SPAs, do NOT add a `[start]` section to `nixpacks.toml`.** For SSR apps that need it, use `vite preview` as the start command.

## Cloudflare Worker bypass (CRITICAL)

If the repo has `wrangler.jsonc`, it deploys as a **Cloudflare Worker** separate from Dokploy. The Worker may be serving traffic INSTEAD of the Dokploy container. Fix: either remove the Worker route in Cloudflare dashboard or re-deploy the Worker with `wrangler deploy`.

## Build prerequisite: placeholder `dist/server/index.js` (CRITICAL)

**On a clean checkout or after `rm -rf dist`, `bun run build` will FAIL.** The `@cloudflare/vite-plugin` validates `main` in `wrangler.jsonc` before Vite runs.

**Workaround:**
```bash
mkdir -p dist/server
echo 'export default { fetch: () => new Response("placeholder") };' > dist/server/index.js
bun run build   # Vite overwrites placeholder with real bundle
```

**⚠️ If using static SPA Worker pattern:** After `bun run build`, copy `worker.js` over `dist/server/index.js`:
```bash
cp src/worker.js dist/server/index.js
# or if worker.js is at project root:
cp worker.js dist/server/index.js
```
The `package.json` build script should handle this automatically.

## Pre-deploy cleanup

```bash
rm -f .wrangler/deploy/config.json dist/server/wrangler.json
```

## Nixpacks `[start]` section

**For pure SPAs:** Do NOT add `[start]` — Nixpacks auto-generates Caddyfile.
**For SSR apps:** `[start]` is needed, use `vite preview` as the command.

## Runtime data in Vite bundles

**Production best practice**: Commit generated data to git so it's baked into the JS bundle at build time. Remove from `.gitignore`, run aggregator locally, commit & push.

## Aggregate memory path configuration

See `references/agentic-os-config.md` for the full configuration.

## Hermes Memory Path Quick Reference

| Path | Exists? | Description |
|------|---------|-------------|
| `/root/ulak/memories/` | ✅ Yes | Ulak snapshot, synced every 30 min |
| `/root/.hermes/memories/` | ✅ Yes | Live Hermes memories (source of truth) |
| `/tmp/hermes-memory/` | ✅ Yes | Staging dir for deploy pipeline |
| `/root/.hermes/memory/` | ❌ No | Singular — does NOT exist |
| `/root/ulak/memory/` | ❌ No | Singular — does NOT exist |

## Cloudflare cache invalidation

After fixing the origin, Cloudflare may still serve stale content. Purge via dashboard: Caching → Purge Everything.

## Overwriting Caddyfile in container

**Use `docker cp`, NOT `docker exec tee`.** The exec tee approach silently fails.
```bash
docker cp /tmp/Caddyfile_fixed <container>:/assets/Caddyfile
docker restart <container>
```

**Cleanest approach:** Place Caddyfile at `.nixpacks/Caddyfile` in repo root — Nixpacks auto-discovers it at build time.

## Debugging Agentic OS dashboard issues

See the extensive debugging sections in the previous version of this skill, covering:
- Memory shows 0 (data flow, isExample flag, demo mode)
- Memory graph blank (chunk hash mismatch, wrangler asset dedup)
- Wrangler deploy issues (stale assets, placeholder responses)

Key files for agentic-os debugging:
- `references/agentic-os-config.md`
- `references/agentic-os-worker-bypass.md`
- `references/agentic-os-version-log.md`
- `references/tanstack-start-1167-server-entry-removed.md`

## Reference Files

- `references/agentic-os.md` — Agentic OS deployment notes
- `references/agentic-os-config.md` — Aggregate memory paths, bun PATH, STALE_DAYS
- `references/agentic-os-worker-bypass.md` — Cloudflare Worker bypass diagnosis
- `references/agentic-os-hermes-integration.md` — Hermes skills scanning, memory sync
- `references/agentic-os-version-log.md` — Full deploy history (r1–r45)
- `references/tanstack-start-ssr-worker-deploy.md` — TanStack Start SSR deploy pattern (pre-1.167)
- `references/tanstack-start-1167-server-entry-removed.md` — **NEW: v1.167+ SSR breakage + static SPA Worker solution**
- `references/worker-html-script-escaping.md` — **NEW: `</script>` / `</style>` escaping in Worker-embedded HTML, KV binding patching, build-worker.mjs pattern**
- `references/2026-06-01-memory-graph-hash-mismatch.md` — Chunk hash mismatch debugging
