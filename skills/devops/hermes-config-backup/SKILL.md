---
name: hermes-config-backup
description: "Backup and sync Hermes/Ulak config to GitHub: persona renaming, what to include/exclude, cron automation, remote setup."
version: 1.1.0
author: Ulak Agent
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [hermes, ulak, backup, github, sync, whatsapp, persona]
---

# Hermes → Ulak Konfigürasyon Yedek ve Uygulama Skill'i

Bu skill, Hermes Agent kurulumunu "Ulak" olarak özelleştiren tüm değişiklikleri belgeler ve güncelleme sonrası otomatik olarak yeniden uygulanmasını sağlar.

## Tetikleyici Koşullar

- `hermes update` sonrası
- Gateway restart sonrası WhatsApp prefix eski haline dönmüşse
- Yeni sunucuya kurulum yapılıyorsa
- `/skill hermes-config-backup` ile manuel çağrıldığında

---

## 1. SOUL.md — Persona / İsim

`~/.hermes/SOUL.md` dosyasını güncelle:

```bash
cat > ~/.hermes/SOUL.md << 'EOF'
# Ulak Agent Persona

<!--
This file defines the agent's personality and tone.
Edit this to customize how Ulak communicates with you.
-->

Sen Ulak'sın — terminal tabanlı, hızlı ve güvenilir bir AI asistan.
EOF
```

---

## 2. WhatsApp Bridge — Prefix ve Browser Kimliği

`/usr/local/lib/hermes-agent/scripts/whatsapp-bridge/bridge.js` içindeki iki satırı değiştir:

```bash
BRIDGE="/usr/local/lib/hermes-agent/scripts/whatsapp-bridge/bridge.js"

# Mesaj prefix
sed -i "s/⚕ \*Hermes Agent\*/⚕ *Ulak Agent*/g" "$BRIDGE"

# Browser kimliği (WhatsApp'ın gördüğü isim)
sed -i "s/browser: \['Hermes Agent'/browser: ['Ulak Agent'/g" "$BRIDGE"

# Doğrulama
grep -n "Ulak Agent" "$BRIDGE"
```

Beklenen çıktı:
```
54:const DEFAULT_REPLY_PREFIX = '⚕ *Ulak Agent*\n────────────\n';
189:    browser: ['Ulak Agent', 'Chrome', '120.0'],
```

---

## 3. config.yaml — Personality İsimleri

```bash
sed -i "s/Captain Hermes/Captain Ulak/g" ~/.hermes/config.yaml
sed -i "s/They call me Hermes/They call me Ulak/g" ~/.hermes/config.yaml
```

---

## 4. Gateway Yeniden Başlat

```bash
hermes gateway restart
sleep 5
curl -s http://localhost:3000/health
# Beklenen: {"status":"connected",...}
```

---

## 5. Tüm Değişiklikleri Tek Seferde Uygula (ulak_apply.sh)

```bash
#!/bin/bash
# ulak_apply.sh — Ulak özelleştirmelerini uygula
# Kullanım: bash ~/.hermes/scripts/ulak_apply.sh

echo "=== Ulak konfigürasyonu uygulanıyor ==="

# 1. SOUL.md
cat > ~/.hermes/SOUL.md << 'SOULEOF'
# Ulak Agent Persona

<!--
This file defines the agent's personality and tone.
Edit this to customize how Ulak communicates with you.
-->

Sen Ulak'sın — terminal tabanlı, hızlı ve güvenilir bir AI asistan.
SOULEOF
echo "✓ SOUL.md güncellendi"

# 2. WhatsApp bridge
BRIDGE="/usr/local/lib/hermes-agent/scripts/whatsapp-bridge/bridge.js"
if [ -f "$BRIDGE" ]; then
  sed -i "s/⚕ \*Hermes Agent\*/⚕ *Ulak Agent*/g" "$BRIDGE"
  sed -i "s/browser: \['Hermes Agent'/browser: ['Ulak Agent'/g" "$BRIDGE"
  echo "✓ WhatsApp bridge güncellendi"
else
  echo "✗ bridge.js bulunamadı: $BRIDGE"
fi

# 3. config.yaml
sed -i "s/Captain Hermes/Captain Ulak/g" ~/.hermes/config.yaml
sed -i "s/They call me Hermes/They call me Ulak/g" ~/.hermes/config.yaml
echo "✓ config.yaml güncellendi"

# 4. Gateway restart
hermes gateway restart
sleep 5
STATUS=$(curl -s http://localhost:3000/health 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('status','?'))" 2>/dev/null || echo "kontrol edilemedi")
echo "✓ Gateway durumu: $STATUS"

echo "=== Ulak konfigürasyonu tamamlandı ==="
```

Script'i kaydet:

```bash
cp ~/.hermes/scripts/ulak_apply.sh ~/.hermes/scripts/ulak_apply.sh 2>/dev/null || true
chmod +x ~/.hermes/scripts/ulak_apply.sh
```

---

## Güncelleme Sonrası Otomatik Uygulama

`hermes update` bridge.js dahil pek çok dosyayı sıfırlayabilir. Güncelleme sonrası hemen çalıştır:

```bash
hermes update && bash ~/.hermes/scripts/ulak_apply.sh
```

---

## GitHub Sync (Ulak Repo)

Tüm değişiklikler `/root/ulak` reposuna her 30 dakikada bir otomatik push edilir (cron job: ulak-github-sync). Manuel sync:

```bash
bash ~/.hermes/scripts/ulak_sync.sh
```

---

## Pitfalls

- `hermes update` bridge.js dosyasını sıfırlar — güncelleme sonrası mutlaka `ulak_apply.sh` çalıştır
- Gateway restart QR kod gerektirmez, mevcut WhatsApp session korunur (`~/.hermes/whatsapp/session`)
- SOUL.md her mesajda yeniden yüklendiği için gateway restart gerekmez, anında etki eder
- config.yaml değişiklikleri için gateway restart gerekli
- bridge.js'te `DEFAULT_REPLY_PREFIX` env var ile override edilebilir: `WHATSAPP_REPLY_PREFIX="⚕ *Ulak Agent*\n────────────\n"` — bu yol kalıcıdır, update'e dayanıklıdır
