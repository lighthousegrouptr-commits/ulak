musikapp: Express.js + PostgreSQL + ACRCloud, /var/www/musikapp, git@github.com:lighthousegrouptr-commits/musikapp.git, SSH auth. Ayrı proje, Ulak sync kapsamı dışında.

Ulak projesi: /root/ulak -> github.com/lighthousegrouptr-commits/ulak, her 30dk cron sync (job: 925ecf983b1d). Kapsam: SOUL.md, memories/, skills/, cron/jobs.json, config/ (secret yok), scripts/.
§
SEO: seo-audit skill created at seo-audit with browser-based audit scripts. Lessons: noai/noimageai robots tag = intentional AI block, not a bug. SPA sites: CMS detection unreliable via console, ask user when unsure. Lighthousegroup site: no analytics/GTM connected, blog is SPA. Semrush MCP configured in config.yaml (semrush-mcp npm, KEY placeholder - user needs to provide real key).
§
Lighthousegroup.net.tr email: Resend + Amazon SES. Domain: notify.lighthousegroup.net.tr. DMARC p=none (monitoring only). IP'ler: 23.251.234.54, 23.251.234.60.

User expects proactive problem-solving. Turkish SEO strategy: block AI engines (noai/noimageai) but allow regular search engines. Blog: weekly Turkish technical posts on AI/GEO/SEO. CMS not yet identified - need repo access or server SSH to connect API. User preferred Semrush MCP but hasn't provided API key yet.
§
Hermes memory path: /root/ulak/memories/ (plural). Aggregate.ts was missing this path - added 2026-06-03. See agentic-os aggregate script memory path fix entry.
§
agentic-os (2026-06-03 r63): aggregate source labeling fixed (hermes/ulak → "hermes" not "obsidian"). Memory graph: All-Obsidian-Claude-Hermes. Browser can't render CF Worker SPAs. <synthetic> JSONL = 0 tokens. KV: df2bda58d7bb4abe91569c4c48c5bf5b.
§
agentic-os (2026-06-03 r64): Deploy fixed - removed build-worker.mjs from package.json (was overwriting TanStack Start SSR output). TanStack outputs server.js not index.js - copy after build. wrangler deploy --config dist/server/wrangler.json. scripts/deploy.sh canonical. KV: df2bda58d7bb4abe91569c4c48c5bf5b. Browser blank = bot detection (normal). <synthetic> JSONL = 0 tokens.