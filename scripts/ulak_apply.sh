#!/bin/bash
# ulak_apply.sh — Ulak özelleştirmelerini uygula
# hermes update sonrası çalıştır: hermes update && bash ~/.hermes/scripts/ulak_apply.sh

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

# 4. cli.py — banner, logo, caduceus, agent_name, status bar
CLI="/usr/local/lib/hermes-agent/cli.py"
if [ -f "$CLI" ]; then
  # Banner metni
  sed -i 's/⚕ NOUS HERMES - AI Agent Framework/⚕ ULAK - AI Agent Framework/g' "$CLI"
  sed -i 's/⚕ NOUS HERMES"/⚕ ULAK"/g' "$CLI"
  # agent_name default
  sed -i "s/get_branding(\"agent_name\", \"Hermes Agent\")/get_branding(\"agent_name\", \"Ulak Agent\")/g" "$CLI"
  sed -i "s/else \"Hermes Agent\"/else \"Ulak Agent\"/g" "$CLI"
  # Status bar
  sed -i "s/else 'Hermes'}/else 'Ulak'}/g" "$CLI"
  echo "✓ cli.py güncellendi"
else
  echo "✗ cli.py bulunamadı: $CLI"
fi

# 4. Gateway restart
hermes gateway restart
sleep 5
STATUS=$(curl -s http://localhost:3000/health 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('status','?'))" 2>/dev/null || echo "kontrol edilemedi")
echo "✓ Gateway durumu: $STATUS"

echo "=== Ulak konfigürasyonu tamamlandı ==="
