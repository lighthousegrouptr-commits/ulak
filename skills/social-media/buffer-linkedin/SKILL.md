---
name: buffer-linkedin
description: "Buffer API ile LinkedIn ve Google Business'a post oluştur, taslak göster, onay al, tek veya çok kanala yayınla."
version: 2.0.0
author: Lighthouse Group
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [LinkedIn, Google Business, Buffer, Social Media, Content, Post, Sosyal Medya, İçerik, Çok Kanal]
    related_skills: []
prerequisites:
  env: [BUFFER_API_TOKEN, BUFFER_LINKEDIN_CHANNEL_ID, BUFFER_GOOGLE_BUSINESS_CHANNEL_ID]
  commands: [curl, python3]
---

# Buffer → Sosyal Medya Post Yönetimi

LinkedIn ve Google Business'a Buffer GraphQL API üzerinden post oluştur.
**Her zaman önce taslak göster, kullanıcı onayı al, sonra yayınla.**

## Aktif Kanallar

| Kanal | Env Değişkeni | Karakter Limiti | Hashtag |
|---|---|---|---|
| LinkedIn | `BUFFER_LINKEDIN_CHANNEL_ID` | 3000 (ideal 1300) | Evet, 3-5 |
| Google Business | `BUFFER_GOOGLE_BUSINESS_CHANNEL_ID` | 1500 (ideal 300-500) | Hayır |

## Tetikleyici Kelimeler

- "linkedin postu yaz", "google business'a yaz", "ikisine birden paylaş"
- "sosyal medyaya at", "buffer'a ekle", "hepsine paylaş"
- "şu konuda post yaz: ...", "duyuru yaz", "tanıtım postu"

---

## Akış — Her Zaman Bu Sırayla

1. **Kanal belirle** → Kullanıcı hangisini istedi? (LinkedIn / Google Business / ikisi)
2. **İçerik üret** → Her kanal için ayrı, platforma uygun metin oluştur
3. **Taslağı göster** → Kullanıcıya sun
4. **Onay bekle** → "onayla", "yayınla", "tamam" gelene kadar BEKLEME
5. **API'ye gönder** → Onay sonrası ilgili kanallara çağrı yap

> ⚠️ Kullanıcı onaylamadan asla `createPost` çağrısı yapma.

---

## İçerik Üretimi Kuralları

### LinkedIn
- Profesyonel ama samimi dil
- 150-300 kelime, 3-5 satır paragraflar
- Sonunda 3-5 hashtag: `#AI #Otomasyon #LighthouseGroup` vb.
- Hedef: iş dünyası, potansiyel müşteriler, partnerler

### Google Business
- Kısa, net, aksiyona yönlendiren (300-500 karakter ideal)
- Hashtag YOK — Google Business desteklemiyor
- Yerel ve hizmet odaklı: "İstanbul'da AI çözümleri"
- CTA ekle: "Bizi arayın", "Web sitemizi ziyaret edin", "Detaylar için tıklayın"
- Hedef: Google'da arayan yerel müşteriler

### Taslağı şu formatta göster:

```
📝 Taslak — [LinkedIn / Google Business / Her İkisi]
══════════════════════════════════════

📌 LinkedIn:
[içerik]
#hashtag1 #hashtag2 #hashtag3

──────────────────────────────────────

📍 Google Business:
[kısa, CTA'lı içerik]

══════════════════════════════════════
Yayın: Kuyruğa ekle  |  Kanal: [belirtilen kanallar]

Onaylamak için : "onayla" / "yayınla"
Değiştirmek için: "linkedin'i değiştir: ..." / "google'ı değiştir: ..."
Hemen yayınlamak için: "şimdi yayınla"
Sadece biri için: "sadece linkedin'e at" / "sadece google'a at"
```

---

## Post Gönderme Fonksiyonu

Tüm yayın işlemleri için bu bash fonksiyonunu kullan:

```bash
buffer_post() {
  local CHANNEL_ID="$1"
  local POST_TEXT="$2"
  local MODE="${3:-addToQueue}"   # addToQueue | shareNow | customScheduled
  local DUE_AT="${4:-}"

  BUFFER_TOKEN="${BUFFER_API_TOKEN}"

  # dueAt alanını koşullu ekle
  if [ -n "$DUE_AT" ]; then
    DUE_AT_FIELD="\"dueAt\": \"${DUE_AT}\","
  else
    DUE_AT_FIELD=""
  fi

  RESPONSE=$(curl -s -X POST "https://api.buffer.com/graphql" \
    -H "Authorization: Bearer ${BUFFER_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{
      \"query\": \"mutation CreatePost(\$input: CreatePostInput!) { createPost(input: \$input) { ... on PostActionSuccess { post { id text status } } ... on InvalidInputError { message } ... on UnexpectedError { message } } }\",
      \"variables\": {
        \"input\": {
          \"channelId\": \"${CHANNEL_ID}\",
          \"text\": $(python3 -c \"import json,sys; print(json.dumps(sys.argv[1]))\" \"$POST_TEXT\"),
          \"schedulingType\": \"automatic\",
          \"mode\": \"${MODE}\",
          ${DUE_AT_FIELD}
          \"assets\": []
        }
      }
    }")

  echo "$RESPONSE" | python3 -c "
import json, sys
d = json.load(sys.stdin)
post = d.get('data', {}).get('createPost', {}).get('post')
if post:
    print(f'✅ Gönderildi! ID: {post[\"id\"]} · Durum: {post[\"status\"]}')
else:
    err = d.get('data',{}).get('createPost',{}).get('message') or str(d.get('errors','?'))
    print(f'❌ Hata: {err}')
"
}
```

---

## 1. Kuyruğa Ekle (Varsayılan)

### Sadece LinkedIn
```bash
buffer_post "${BUFFER_LINKEDIN_CHANNEL_ID}" "LinkedIn metin buraya" "addToQueue"
```

### Sadece Google Business
```bash
buffer_post "${BUFFER_GOOGLE_BUSINESS_CHANNEL_ID}" "Google Business metin buraya" "addToQueue"
```

### Her İkisine Birden ("ikisine de paylaş" / "hepsine at")
```bash
LI_TEXT="LinkedIn için metin"
GB_TEXT="Google Business için kısa metin"

echo "LinkedIn gönderiliyor..."
buffer_post "${BUFFER_LINKEDIN_CHANNEL_ID}" "$LI_TEXT" "addToQueue"

echo "Google Business gönderiliyor..."
buffer_post "${BUFFER_GOOGLE_BUSINESS_CHANNEL_ID}" "$GB_TEXT" "addToQueue"
```

---

## 2. Hemen Yayınla ("şimdi yayınla")

```bash
buffer_post "${BUFFER_LINKEDIN_CHANNEL_ID}" "Metin buraya" "shareNow"
buffer_post "${BUFFER_GOOGLE_BUSINESS_CHANNEL_ID}" "Metin buraya" "shareNow"
```

---

## 3. Tarihe Planla ("Pazartesi 09:00'da yayınla")

Türkiye UTC+3 — API'ye 3 saat çıkararak gönder:

```bash
# Pazartesi 09:00 TR = 06:00 UTC
DUE_AT="2026-06-22T06:00:00.000Z"
buffer_post "${BUFFER_LINKEDIN_CHANNEL_ID}" "Metin buraya" "customScheduled" "$DUE_AT"
```

---

## 4. Planlanmış Postları Listele

```bash
curl -s -X POST "https://api.buffer.com/graphql" \
  -H "Authorization: Bearer ${BUFFER_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ posts(input: { organizationId: \"6a09c284a6b80028aff1c42f\" }) { edges { node { id text status } } } }"}' \
  | python3 -c "
import json, sys
d = json.load(sys.stdin)
posts = d.get('data', {}).get('posts', {}).get('edges', [])
if not posts:
    print('Planlanmış post yok.')
else:
    for p in posts:
        n = p['node']
        print(f'[{n[\"status\"]}] {n[\"id\"]}: {n[\"text\"][:80]}')
"
```

---

## 5. Post Sil

```bash
POST_ID="silinecek_id"
curl -s -X POST "https://api.buffer.com/graphql" \
  -H "Authorization: Bearer ${BUFFER_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"query\": \"mutation { deletePost(input: { id: \\\"${POST_ID}\\\" }) { ... on DeletePostSuccess { id } ... on VoidMutationError { message } } }\"}" \
  | python3 -c "
import json, sys
d = json.load(sys.stdin)
r = d.get('data', {}).get('deletePost', {})
print('✅ Silindi: ' + r['id'] if r.get('id') else '❌ Hata: ' + r.get('message', str(d)))
"
```

---

## Komut Referansı

| Kullanıcı der ki | Hermes ne yapar |
|---|---|
| "linkedin postu yaz: ..." | LinkedIn taslağı üret, göster |
| "google business'a yaz: ..." | Google Business taslağı üret, göster |
| "ikisine birden paylaş" / "hepsine at" | Her iki kanal için ayrı taslak üret |
| "onayla" / "yayınla" / "tamam" | `addToQueue` → Buffer kuyruğuna ekle |
| "şimdi yayınla" | `shareNow` → anında yayınla |
| "Pazartesi 09:00'da yayınla" | `customScheduled` → tarihe planla |
| "sadece linkedin'e at" | Yalnızca LinkedIn kanalına gönder |
| "sadece google'a at" | Yalnızca Google Business kanalına gönder |
| "linkedin'i değiştir: ..." | LinkedIn taslağını güncelle, tekrar göster |
| "google'ı değiştir: ..." | Google Business taslağını güncelle |
| "planlanmış postları göster" | `posts` query → liste döndür |
| "son postu sil" / "iptal et" | Post ID al, `deletePost` çalıştır |

---

## Önemli Notlar

- **Dil:** Kullanıcı Türkçe yazıyorsa Türkçe içerik üret
- **Ton:** Profesyonel, samimi, çözüm odaklı — Lighthouse Group sesi
- **Zaman dilimi:** Türkiye UTC+3 — API'ye gönderirken 3 saat çıkar
- **Google Business hashtag:** Desteklenmiyor, ekleme
- **Onaysız yayın:** Asla — kullanıcı açıkça onaylamadan hiçbir `createPost` çağrısı yapma
