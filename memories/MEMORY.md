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
Backlink stratejisi: emergent-fabric.lovable.app (Synthetic Intelligence sayfası) ile lighthousegroup.net.tr arasında karşılıklı backlink planı yapılacak. Şimdi değil, daha sonra yapılacak. Footer'da zaten lighthousegroup.net.tr linki mevcut.
§
agentic-os deployment resolved (2026-05-30):
- Repo: lighthousegrouptr-commits/agentic-os, Nixpacks build type
- .nixpacks/Caddyfile override fixes broken $NIXPACKS_SPA_OUTPUT_DIR (was causing 404s)
- live-data.json committed to git — provides pre-aggregated data for builds (no ~/.claude in container)
- Cron on VPS: /usr/local/bin/refresh-agentic-data every 30min (aggregate inside container → dist/client/live-data.json)
- useLiveData.ts: /live-data.json in prod, /__live-data in dev, staleTime=30s
- do NOT add [start] to nixpacks.toml — breaks deploy with "Module not found dist/server/index.js"