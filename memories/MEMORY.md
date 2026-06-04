musikapp: Express.js + PostgreSQL + ACRCloud, /var/www/musikapp, git@github.com:lighthousegrouptr-commits/musikapp.git, SSH auth. Ayrı proje, Ulak sync kapsamı dışında.

Ulak projesi: /root/ulak -> github.com/lighthousegrouptr-commits/ulak, her 30dk cron sync (job: 925ecf983b1d). Kapsam: SOUL.md, memories/, skills/, cron/jobs.json, config/ (secret yok), scripts/.
§
SEO: seo-audit skill created at seo-audit with browser-based audit scripts. Lessons: noai/noimageai robots tag = intentional AI block, not a bug. SPA sites: CMS detection unreliable via console, ask user when unsure. Lighthousegroup site: no analytics/GTM connected, blog is SPA. Semrush MCP configured in config.yaml (semrush-mcp npm, KEY placeholder - user needs to provide real key).
§
Lighthousegroup.net.tr email: Resend + Amazon SES. Domain: notify.lighthousegroup.net.tr. DMARC p=none (monitoring only). IP'ler: 23.251.234.54, 23.251.234.60.

User expects proactive problem-solving. Turkish SEO strategy: block AI engines (noai/noimageai) but allow regular search engines. Blog: weekly Turkish technical posts on AI/GEO/SEO. CMS not yet identified - need repo access or server SSH to connect API. User preferred Semrush MCP but hasn't provided API key yet.
§
agentic-os worker: Standalone worker + TanStack Start UI birlikte çalışıyor. Pipeline: Docker hermetic aggregate → /opt/agentic-os/src/data/live-data.json → bun run build → wrangler deploy (cron /usr/local/bin/refresh-agentic-data, her 30dk). Kritik: bun PATH'te değil, script başında export PATH="$PATH:/root/.bun/bin" şart. KV: df2bda58d7bb4abe91569c4c48c5bf5b. Veri root'ta generatedAt zorunlu. /__live-data endpoint JSON dönüyor = sağlıklı. 2026-06-04 onarımı: Dashboard boş geliyordu, standalone worker'a gerilemişti, TanStack UI restore edildi. 2026-06-04 tekrar: "eski worker'a dönelim" dedi ama zaten eski worker (standalone) çalışıyormuş, bir şey istemedi, sadece hafızamı güncellemek istedi.
