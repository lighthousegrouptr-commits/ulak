musikapp: Express.js + PostgreSQL + ACRCloud, /var/www/musikapp, git@github.com:lighthousegrouptr-commits/musikapp.git, SSH auth. Ayrı proje, Ulak sync kapsamı dışında.

Ulak projesi: /root/ulak -> github.com/lighthousegrouptr-commits/ulak, her 30dk cron sync (job: 925ecf983b1d). Kapsam: SOUL.md, memories/, skills/, cron/jobs.json, config/ (secret yok), scripts/.
§
Levent bilgisayarı için SSH kısayolu isteği: ssh root@187.77.79.159
§
SEO: seo-audit skill created at seo-audit with browser-based audit scripts. Lessons: noai/noimageai robots tag = intentional AI block, not a bug. SPA sites: CMS detection unreliable via console, ask user when unsure. Lighthousegroup site: no analytics/GTM connected, blog is SPA. Semrush MCP configured in config.yaml (semrush-mcp npm, KEY placeholder - user needs to provide real key).
§
Lighthousegroup.net.tr email: Resend + Amazon SES. Domain: notify.lighthousegroup.net.tr. DMARC p=none (monitoring only). IP'ler: 23.251.234.54, 23.251.234.60.

User expects proactive problem-solving. Turkish SEO strategy: block AI engines (noai/noimageai) but allow regular search engines. Blog: weekly Turkish technical posts on AI/GEO/SEO. CMS not yet identified - need repo access or server SSH to connect API. User preferred Semrush MCP but hasn't provided API key yet.
§
Hermes memory path: /root/ulak/memories/ (plural). Aggregate.ts already scans this path. No code patch needed.
§
agentic-os: /root/code/agentic-os, Cloudflare Worker deploy. Worker name: tanstack-start-app. STALE_DAYS=30 in aggregate.ts. live-data.json committed to git. Cron 2655c3b31f43 auto-deploys. wrangler deploy always uses dist/server/wrangler.json (Vite-generated), ignores custom file args. Has assets.directory=../client. Worker.js must be at dist/server/index.js or assets removed. KV HTML pattern: store HTML in KV, keep worker.js <2KB. KV live-data must be uploaded after each aggregate.