musikapp: Express.js + PostgreSQL + ACRCloud, /var/www/musikapp, git@github.com:lighthousegrouptr-commits/musikapp.git, SSH auth. Ayrı proje, Ulak sync kapsamı dışında.

Ulak projesi: /root/ulak -> github.com/lighthousegrouptr-commits/ulak, her 30dk cron sync (job: 925ecf983b1d). Kapsam: SOUL.md, memories/, skills/, cron/jobs.json, config/ (secret yok), scripts/.
§
SEO: seo-audit skill created at seo-audit with browser-based audit scripts. Lessons: noai/noimageai robots tag = intentional AI block, not a bug. SPA sites: CMS detection unreliable via console, ask user when unsure. Lighthousegroup site: no analytics/GTM connected, blog is SPA. Semrush MCP configured in config.yaml (semrush-mcp npm, KEY placeholder - user needs to provide real key).
§
Lighthousegroup.net.tr email: Resend + Amazon SES. Domain: notify.lighthousegroup.net.tr. DMARC p=none (monitoring only). IP'ler: 23.251.234.54, 23.251.234.60.

User expects proactive problem-solving. Turkish SEO strategy: block AI engines (noai/noimageai) but allow regular search engines. Blog: weekly Turkish technical posts on AI/GEO/SEO. CMS not yet identified - need repo access or server SSH to connect API. User preferred Semrush MCP but hasn't provided API key yet.
§
Hermes memory path: /root/ulak/memories/ (plural). Aggregate.ts already scans this path. No code patch needed.
§
agentic-os: /opt/agentic-os, Worker: tanstack-start-app. SPA deploy (ONLY path): `bun run build` → patch dist/server/wrangler.json (KV: df2bda58d7bb4abe91569c4c48c5bf5b, route: agentic.lighthousegroup.net.tr/*, zone: 6d59ce28d0fc5cdb1a71b401d7e5f366) → `cd dist/server && npx wrangler deploy`. Minimal HTML workers FAIL — Zaraz destroys scripts. Zaraz fix: exclude subdomain in CF dashboard.
§
agentic-os: /opt/agentic-os, Worker: tanstack-start-app. SPA deploy ONLY. Deploy: aggregate → build → patch dist/server/wrangler.json → rm -rf .wrangler → cd dist/server && wrangler deploy. KV: df2bda58d7bb4abe91569c4c48c5bf5b. Zone: 6d59ce28d0fc5cdb1a71b401d7e5f366. Account: 32eb17ead96931c13af8500327096aaf.