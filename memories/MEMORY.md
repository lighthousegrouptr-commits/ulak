musikapp: Express.js + PostgreSQL + ACRCloud, /var/www/musikapp, git@github.com:lighthousegrouptr-commits/musikapp.git, SSH auth. Ayrı proje, Ulak sync kapsamı dışında.

Ulak projesi: /root/ulak -> github.com/lighthousegrouptr-commits/ulak, her 30dk cron sync (job: 925ecf983b1d). Kapsam: SOUL.md, memories/, skills/, cron/jobs.json, config/ (secret yok), scripts/.
§
Levent bilgisayarı için SSH kısayolu isteği: ssh root@187.77.79.159
§
Test memory entry
§
Hafıza sorgusu - 25 Mayıs 2026
§
Dokploy sorgusu - 25 Mayıs 2026
§
Türkiye 2026 Resmi Tatil ve Bayram Günleri (tam liste):

SABİT MİLLİ TATİLLER:
- 1 Ocak (Perşembe) - Yılbaşı
- 23 Nisan (Perşembe) - Ulusal Egemenlik ve Çocuk Bayramı (2026 geçti)
- 1 Mayıs (Cuma) - Emek ve Dayanışma Günü (2026 geçti)
- 19 Mayıs (Salı) - Atatürk'ü Anma, Gençlik ve Spor Bayramı (2026 geçti)
- 15 July (Çarşamba) - Demokrasi ve Millî Birlik Günü
- 30 August (Pazar) - Zafer Bayramı
- 28 Ekim (Çarşamba) - Cumhuriyet Bayramı Yarım Gün (öğleden sonra)
- 29 Ekim (Perşembe) - Cumhuriyet Bayramı

DİNİ BAYRAMLAR (2026, Ay'a göre kesinleşir):
- Ramazan Bayramı (1-3 Şevval 1447): ~19-21 Mart 2026 (3 gün, muhtemelen geçti)
- Kurban Bayramı (10-13 Zilhicce 1447): ~27-30 Mayıs 2026 (4 gün)

NOT: İslami bayramların kesin tarihleri Diyanet İşleri Başkanlığı tarafından Ay'ın görünmesine göre açıklanır. Hicri takvim her yıl ~10-11 gün öne kayar. Toplam 15.5 gün resmi tatil.§
VPS Talep Formu Pattern (lighthousegroup.net.tr'den öğrenildi - 26 Mayıs 2026):

Yeni site için talep formu kurulurken şu hataları yapma:
1. Cloudflare Turnstile: size="invisible" GEÇERSİZ. Geçerliler: compact/flexible/normal. Kullan: appearance="interaction-only" (size YOK).
2. Admin dashboard Basic Auth: JS fetch() auth header taşımaz. Çözüm: sayfa serve edilirken req.headers['authorization'] değerini HTML'e inject et (__AUTH_TOKEN__ placeholder).
3. Dokploy env var'lar: docker service update --env-add geçici, redeploy'da silinir. Kalıcı için Dokploy PostgreSQL'deki application tablosunu da güncelle.
4. Kod değişikliği: docker cp kalıcı değil. Doğrusu: docker build → docker service update --force.

Skill: ~/.hermes/skills/software-development/vps-contact-form/SKILL.md
Örnek kod: /etc/dokploy/applications/lighthousegoup-web-api-7za9hr/code/api/server.js
Admin panel: https://api.lighthousegroup.net.tr/admin (admin / ADMIN_PASSWORD)
