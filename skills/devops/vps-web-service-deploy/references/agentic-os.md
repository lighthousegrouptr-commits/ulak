# Agentic OS — deployment notes

**URL**: https://agentic.lighthousegroup.net.tr/
**Repo**: `lighthousegrouptr-commits/agentic-os` (GitHub — forked from `sasdsamatt123/agentic-os`)
**Swarm service**: `hermetic-agenticos-fax02n`
**Traefik config**: `/etc/dokploy/traefik/dynamic/hermetic-agenticos-fax02n.yml` (routes to `http://hermetic-agenticos-fax02n:3000`)

## CRITICAL: Project identity

This is **NOT** musikapp. Musikapp is a completely separate project. When the user says
"agentic-os" or "dashboard" or "agentic", they mean this project only.

## Git access

Both `lighthousegrouptr-commits` keys authenticate to GitHub. `~/.ssh/config` routes all `github.com`
traffic through `musikapp` key, but both keys (`id_ed25519`, `musikapp`) map to the same account.

The repo was migrated FROM `sasdsamatt123/agentic-os` TO `lighthousegrouptr-commits/agentic-os`.
The local remote was updated accordingly:
```
git remote set-url origin git@github.com:lighthousegrouptr-commits/agentic-os.git
```

Had to `git pull --rebase --allow-unrelated-histories` because remote had divergent history.

## Architecture

This is a **TanStack Start SSR app** with `@cloudflare/vite-plugin` — it produces both
`dist/client/` (assets) and `dist/server/` (SSR worker entry). There is NO `index.html` —
every request is server-side rendered. This means:

- Nixpacks' default Caddy static file serving **will not work** (no `index.html` → 404)
- Start command must be `bun run preview` with explicit port/host flags
- `[start]` section in `nixpacks.toml` **IS required** for this app type (exception to the general rule)

## Deployment solution (adopted 2026-05-30)

### 1. Caddyfile override (`.nixpacks/Caddyfile` in repo)

Place at `.nixpacks/Caddyfile` in the project root. Nixpacks auto-discovers
`.nixpacks/assets/` and copies to `/assets/` at build time.

### 2. `nixpacks.toml`

```toml
[phases.setup]
nixPkgs = ["bun"]

[phases.build]
cmds = [
  "bun install --frozen-lockfile",
  "bun run scripts/aggregate.ts || true",
  "bun run build"
]

[start]
cmd = "bun --bun node_modules/.bin/vite preview --port 3000 --host 0.0.0.0"
```

**CRITICAL: Port must be 3000 and host must be 0.0.0.0.** Vite preview defaults to port 4173, but
Traefik routes to container port 3000. Without `--port 3000`, the container starts fine but all
requests get connection refused (Traefik → container:3000, but Vite listens on :4173). Without
`--host 0.0.0.0`, Vite only listens on loopback and Swarm can't reach it from the ingress network.

### 3. Data strategy

- `live-data.json` committed to git (un-ignored) → bundled at build time with real data
- Runtime refresh via host-side cron that `docker exec`s into container to re-run aggregate
- `useLiveData.ts`: static import in prod, `/__live-data` fetch in dev, staleTime 30s

## Runtime aggregate results (sample)

Successful aggregate run inside container produced:
- 2 projects, 1458 assistant msgs
- 12 memory files / 1 workspace / 14 events
- 5 skills installed / 5 used / 6 runs in last 7d
- $151.82 value extracted last 7d
- Claude: oauth, ChatGPT: none, OpenRouter: missing

## Files added to repo

- `.nixpacks/Caddyfile` — overrides Nixpacks' auto-generated Caddyfile with absolute `root * /app/dist/client`
- `nixpacks.toml` — build phase with aggregate + `[start]` for SSR preview
- `scripts/refresh-data.sh` — host-side cron script: docker exec → aggregate → copy to dist/client
- `src/data/live-data.json` — committed to git (un-ignored) for build-time data bundling

## Caddyfile injection method (fallback)

If `.nixpacks/Caddyfile` doesn't work and you need post-deploy Caddyfile changes:

`docker exec` tee/heredoc **silently fails** in Nixpacks containers. Use `docker cp`:

```bash
scp Caddyfile_fixed root@<host>:/tmp/Caddyfile_fixed
docker cp /tmp/Caddyfile_fixed <container>:/assets/Caddyfile
docker restart <container>
```

## Mount configuration

For runtime aggregate to read real `~/.claude/` data inside the container:

```bash
docker service update --mount-add type=bind,source=/root/.claude,target=/root/.claude,readonly=true hermetic-agenticos-fax02n
```

## Swarm service gotchas

- `docker service force-update` does NOT exist in this Swarm version
- `docker service update --mount-add` works
- Old containers linger after service update — check `docker ps | grep <name>`
- `docker exec` tee/heredoc silently fails (tool policy blocks) — use `docker cp`

## Key lessons from debugging

### Nixpacks + SSR frameworks
- No `index.html` in `dist/client/` — Nixpacks' Caddy static serving returns 404
- Solution: `[start] cmd = "bun run preview --port 3000 --host 0.0.0.0"` in `nixpacks.toml`
- `dist/server/index.js` is a worker entry point (Cloudflare Workers), NOT a standalone Node server
- NEVER reference `dist/server/index.js` as a start command
- **`[start]` section WORKS for SSR apps** — the earlier crashes were caused by referencing wrong
  files (e.g. `dist/server/index.js`), not by the `[start]` section itself. As long as the start
  command is a valid bin/script, the container starts fine.

### Vite preview port gotcha (IMPORTANT)
- `bun run preview` (and `vite preview`) defaults to **port 4173**, NOT 3000
- Traefik routes to container port 3000 → connection refused if Vite is on 4173
- ALWAYS pass `--port 3000 --host 0.0.0.0` to vite preview
- Without `--host 0.0.0.0`, Vite binds only to `127.0.0.1` and Swarm ingress can't reach it
- Symptoms of wrong port: container shows "Running" in `docker ps`, `docker logs` shows
  "✓ vite preview" with port 4173, but all HTTP requests to the domain return connection refused
  or time out

### Nixpacks Caddyfile
- Default uses `root * ../app/{$NIXPACKS_SPA_OUTPUT_DIR}` — broken (Railway template syntax)
- Override at `.nixpacks/Caddyfile` in repo → copied to `/assets/` at build time
- Use absolute paths: `root * /app/dist/client`
- Port: `:3000` (not `{$PORT:3000}`)
- `caddy fmt --overwrite` is applied by Nixpacks to your Caddyfile — syntax must be valid

### `handle` vs `handle_path` (Caddy trap)
- `handle_path /__live-data` only matches `/__live-data/*` (with trailing slash + subpath)
- Use `handle /__live-data` for exact path matching

### Build container limitations
- No `~/.claude/` — aggregate runs empty in build phase
- Fix: commit `live-data.json` to git (un-ignore in `.gitignore`)
- `COPY . /app` happens AFTER build — can overwrite `dist/` with stale repo files
  (mitigated by `.gitignore` on `dist/`)

### Data persistence
- Production data is baked at build time → stale until next deploy
- Runtime refresh via host cron: docker exec → aggregate → copy to `dist/client/live-data.json`
- React Query `staleTime: 30_000` picks up refreshed data
- Install refresh script as `/usr/local/bin/refresh-<service>-data` via SSH heredoc

### Cloudflare cache
- All `*.lighthousegroup.net.tr` domains use Cloudflare proxy
- After fixing origin: Cloudflare dashboard → Caching → Purge Everything
- Browser: Ctrl+Shift+R or incognito window

## Known issues

- `wrangler pages dev` fails on this VPS (no `wrangler:modules-watch`)
- Node.js on host is v20; wrangler requires v22+
- Multiple Swarm containers may run simultaneously during deploy — check `docker ps`
- `caddy reload` fails when `admin off` — must `docker restart <container>`
