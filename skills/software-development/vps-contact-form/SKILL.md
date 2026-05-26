---
name: vps-contact-form
description: "Dokploy VPS'te talep formu kurulum adımları: Turnstile + PostgreSQL + Resend + admin panel. Yeni site eklendiğinde uygula."
version: 1.0.0
author: Lighthouse Group
platforms: [linux]
metadata:
  hermes:
    tags: [vps, dokploy, contact-form, postgresql, resend, turnstile, admin-panel, express]
    related_skills: [devops, software-development]
---

# VPS Talep Formu + Admin Dashboard

Lighthouse Group VPS (Dokploy + Traefik) için talep formu kurulum rehberi.
Referans: `lighthousegroup.net.tr` → `api.lighthousegroup.net.tr/admin`

## Kritik Hatalar (Bunları Unutma)

### 1. Turnstile `size: "invisible"` çalışmaz
Geçerli değerler: `"compact"`, `"flexible"`, `"normal"`.
`"invisible"` render sırasında exception fırlatır → token hiç oluşmaz → form çalışmaz.
Doğrusu: `appearance: "interaction-only"` kullan, `size` parametresi ekleme.

### 2. Admin dashboard fetch'leri Basic Auth taşımaz
Tarayıcı Basic Auth kimliğini JS fetch'e otomatik eklemez.
Çözüm: Sayfa render edilirken auth token'ı HTML'e göm:
- Route'ta: `html.replace('__AUTH_TOKEN__', req.headers['authorization'])`
- HTML JS'de: `fetch(url, { headers: { 'Authorization': AUTH } })`

**KRİTİK: URL'de credential varsa fetch() patlar**
Chrome/Chromium'da `https://user:pass@site.com/page` şeklinde girilen URL'de
`fetch('/api/...')` çağrısı şu hatayı verir:
`TypeError: Failed to execute 'fetch' on 'Window': Request cannot be constructed
from a URL that includes credentials`
Çözüm: Admin sayfasına credential'sız gir (`https://site.com/admin`),
tarayıcı Basic Auth popup'ında kullanıcı adı/şifre gir. Bu şekilde URL'de
credential olmaz ve JS fetch() normal çalışır.

### 3. Dokploy env var'ları her redeploy'da sıfırlanır
`docker service update --env-add` geçici. Kalıcı için Dokploy PostgreSQL'e yaz:
```
docker exec dokploy-postgres.1.<id> psql -U dokploy -d dokploy -c \
  "UPDATE application SET env='KEY=val\n...' WHERE \"applicationId\"='<id>'"
```

### 4. Image rebuild gerekli, docker cp yetmez
Docker Swarm container'ı image'dan başlar. Kod değişikliği için:
1. `docker build -t <service>:latest .`
2. `docker service update --force <service>`

## Adımlar

1. PostgreSQL tablosu: `contact_submissions` (id, name, company, sector, phone, email, message, locale, source, created_at)
2. Express API: `/api/contact` (Turnstile verify → DB insert → Resend mail)
3. Admin rotaları: `GET /admin` (HTML), `/api/admin/submissions` (JSON+CSV), basicAuth ile korumalı
4. Env var'lar: DATABASE_URL, RESEND_API_KEY, TURNSTILE_SECRET_KEY, ADMIN_PASSWORD
5. Resend DNS: `notify.<domain>` subdomaininde DKIM + SPF + DMARC (Cloudflare proxy kapalı)
6. Dokploy DB'ye env var'ları kaydet
7. Image rebuild + deploy

## Admin Dashboard Adresi

`https://api.<domain>/admin` — Kullanıcı: `admin`, Şifre: ADMIN_PASSWORD env var

## Mevcut Örnek Kod

VPS'te: `/etc/dokploy/applications/lighthousegoup-web-api-7za9hr/code/api/server.js`

## Doğrulama / Test Adımları

Kurulum sonrası veya şüphe durumunda sırayla kontrol et:

```bash
# 1. Container durumu
docker ps --filter "name=lighthouse" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 2. Health check (external)
curl -s https://api.<domain>/api/health
# Beklenen: {"status":"ok","service":"lighthouse-api",...}

# 3. Contact endpoint (token olmadan)
curl -s -X POST https://api.<domain>/api/contact \
  -H "Content-Type: application/json" \
  -d '{"name":"test","email":"test@test.com","message":"test"}'
# Beklenen: {"error":"Güvenlik doğrulaması başarısız."} ← bu NORMAL, Turnstile token gerekli

# 4. Admin panel (Basic Auth)
curl -s -o /dev/null -w "%{http_code}" https://api.<domain>/admin
# Beklenen: 401 (auth olmadan)
```

NOT: Container içinde curl yok. Testler external curl ile yapılmalı.
NOT: Turnstile token olmadan contact endpoint'in hata dönmesi beklenen güvenlik davranışıdır.
