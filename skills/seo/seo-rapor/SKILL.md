---
name: seo-rapor
description: "Google Search Console'dan son 7 günlük SEO özeti: tıklama, gösterim, CTR, ortalama pozisyon. WhatsApp'a özet gönderir."
version: 1.0.0
author: Lighthouse Group
platforms: [linux]
metadata:
  hermes:
    tags: [seo, gsc, rapor, tıklama, gösterim, ctr, pozisyon, anadoluterra, lighthouse]
prerequisites:
  mcp: [gsc-server]
---

# SEO Haftalık Rapor

Son 7 günlük GSC verisini çekip özet rapor üret.

## Tetikleyiciler

- "seo rapor", "seo özeti", "seo durum"
- "anadoluterra rapor", "site performans"
- "bu hafta kaç tıklama", "arama sonuçları nasıl"

## Adımlar

1. `gsc_list_sites` ile mevcut siteleri listele
2. Her site için `gsc_search_analytics` çağır:
   - `startDate`: 7 gün önce (YYYY-MM-DD)
   - `endDate`: bugün (YYYY-MM-DD)
   - `dimensions`: ["date"]
   - `metrics`: ["clicks", "impressions", "ctr", "position"]
3. Verileri topla ve şu formatta özetle:

```
📊 SEO Rapor — [site] — son 7 gün

🖱️ Tıklama:    X
👁️ Gösterim:   X
📈 CTR:        %X.X
📍 Ort. Pozisyon: X.X

En iyi 3 gün: [tarih: tıklama]
Geçen haftaya göre: ↑↓ fark varsa belirt
```

4. Birden fazla site varsa her birini ayrı blok olarak yaz
5. En sona kısa yorum ekle: "Bu hafta dikkat çeken trend: ..."

## Notlar

- Tarih formatı: `datetime.now()` ile hesapla, hardcode etme
- CTR'ı yüzde olarak göster (0.045 → %4.5)
- Pozisyon küçüldükçe iyidir (1 = en iyi)
- Veri yoksa "Bu site için henüz yeterli veri yok" yaz
