# Cloudflare Worker Bypass — agentic-os debugging notes

## The problem

`agentic.lighthousegroup.net.tr` had TWO deploys running simultaneously:

1. **Dokploy container** (Nixpacks + Vite preview on port 3000) — the "real" deploy we were fixing
2. **Cloudflare Worker** (`tanstack-start-app`, `wrangler.jsonc` in repo root) — deployed manually via Wrangler, configured as a custom domain route in Cloudflare

The Cloudflare Worker was in front of the Dokploy container. Every request hit the Worker first, which served its own (stale) bundle — the Dokploy container was never reached. All our Nixpacks/Dokploy fixes had no effect because the Worker was intercepting traffic.

## Diagnosis clues

- `cf-ray` + `server-timing: cfEdge;dur=X,cfOrigin;dur=0,cfWorker;dur=Y` headers — `cfWorker` > 0 means a Worker executed
- `content-encoding: zstd` — Cloudflare's compression (not origin's)
- Status 200 with stale content despite origin being fixed
- Response time ~300ms (90ms Worker + 294ms edge) vs origin-only ~10ms

## Fix options

1. **Remove the Worker route** (Cloudflare dashboard → Workers Routes → delete `agentic.lighthousegroup.net.tr/*`)
2. **Re-deploy the Worker** with current code — see "Deploy workflow" below
3. **Restrict Worker to specific paths** (e.g. only `sitemap.xml*`, leaving `/*` to origin)

## Deploy workflow (Cloudflare Worker)

The `agentic-os` repo has **two separate deploy targets** in the same repo:

```
agentic-os/
  wrangler.jsonc     # Cloudflare Worker (name: tanstack-start-app)
  nixpacks.toml      # Nixpaks/Dokploy config
  src/server.ts      # Worker entry point (Tanstack Start SSR)
```

To deploy the Worker with fresh code (including latest `live-data.json`):

```bash
# From repo root (on any machine with wrangler + Cloudflare auth)
cd /root/code/agentic-os
bun run build          # produces dist/ (both client + server)
wrangler deploy        # uploads to Cloudflare Workers
```

- `wrangler` is pre-installed at `/usr/bin/wrangler` on the Lighthousegroup VPS
- Auth: `lighthousegrouptr@gmail.com` (User API Token)
- Deploy output shows: `Uploaded tanstack-start-app (X sec)` + `Current Version ID: X`
- After deploy, Worker serves updated code within ~30 seconds
- **No Cloudflare cache purge needed** for Worker deploys — new version goes live immediately

## wrangler.jsonc location

```
agentic-os/
  wrangler.jsonc     # Cloudflare Worker config (name: tanstack-start-app)
  nixpacks.toml      # Nixpaks/Dokploy config (separate deploy)
  src/server.ts      # Worker entry point
```

Both deploy targets exist in the same repo. Know which one is actually serving traffic before debugging.

## Repo provenance

- Original template: `sasdsamatt123/agentic-os`
- Production fork: `lighthousegrouptr-commits/agentic-os` (push here with `lighthousegrouptr-commits` SSH key)

## Key lesson

When debugging "why aren't my changes showing up?" on `*.lighthousegroup.net.tr`:
1. First check Cloudflare Workers dashboard for active Workers on that domain
2. Check Workers Routes for catch-all `/*` routes
3. A Worker in front of origin will bypass ALL origin-side fixes until the Worker itself is updated or removed
4. `wrangler.jsonc` in repo root = Cloudflare Worker deploy target (not Nixpacks)
