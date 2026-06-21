---
name: keyword-firsatlar
description: "GSC'den pozisyon 5-20 arasındaki anahtar kelimeleri çeker. Az dokunuşla üst sıralara çıkabilecek fırsatları listeler."
version: 1.0.0
author: Lighthouse Group
platforms: [linux]
metadata:
  hermes:
    tags: [seo, keyword, anahtar kelime, fırsat, pozisyon, içerik, gsc, quick wins]
prerequisites:
  mcp: [gsc-server]
---

# Keyword Fırsat Analizi

Pozisyon 5-20 arasındaki anahtar kelimeleri bul — bunlar en hızlı rank atlayabilecek sayfalardır.

## Tetikleyiciler

- "keyword fırsatlar", "kelime fırsatları", "hangi kelimeler"
- "quick wins", "hızlı seo", "rank atlayacak"
- "içerik fırsatı", "hangi sayfayı güçlendirsem"
- "anahtar kelime analiz"

## Adımlar

1. `gsc_list_sites` ile siteleri al
2. Her site için `gsc_search_analytics` çağır:
   - `startDate`: 28 gün önce
   - `endDate`: bugün
   - `dimensions`: ["query", "page"]
   - `metrics`: ["clicks", "impressions", "ctr", "position"]
   - `rowLimit`: 100
3. Sonuçları filtrele:
   - Pozisyon 5 ile 20 arasında olanlar
   - Gösterim >= 50 (yeterli arama hacmi var)
4. Şu kriterlere göre puanla ve sırala:
   - Yüksek gösterim + düşük CTR = büyük fırsat (başlık/meta iyileştir)
   - Pozisyon 5-10 = biraz içerik güçlendir, rank atlar
   - Pozisyon 10-20 = daha fazla içerik gerekli ama ulaşılabilir

5. En iyi 10 fırsatı şu formatta listele:

```
🎯 Keyword Fırsatları — [site] — son 28 gün

🔥 Hızlı Kazanımlar (Poz. 5-10):
1. "[kelime]" — Poz: X.X | Gösterim: X | CTR: %X
   📄 Sayfa: /...
   💡 Öneri: [başlık optimize et / iç link ekle / içerik genişlet]

⚡ Orta Vadeli (Poz. 10-20):
4. "[kelime]" — Poz: X.X | Gösterim: X | CTR: %X
   📄 Sayfa: /...
   💡 Öneri: [yeni bölüm ekle / rakip analiz yap]
```

6. Sona genel yorum ekle: "Bu ay odaklanman gereken 3 öncelik: ..."

## Öneri Mantığı

- CTR < %2 ve pozisyon < 10 → title/description yaz
- Gösterim yüksek ama tıklama düşük → snippet çekici değil
- Pozisyon 15-20 → o sayfaya iç link ver veya içeriği 300 kelime genişlet
- Aynı kelimede birden fazla sayfa varsa → kanibalizasyon uyarısı ver
