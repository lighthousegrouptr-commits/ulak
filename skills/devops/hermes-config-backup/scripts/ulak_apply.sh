#!/bin/bash
# ulak_apply.sh — Re-apply all Ulak branding customizations after hermes update
# Usage: bash ~/.hermes/scripts/ulak_apply.sh
# Full pipeline: hermes update && bash ~/.hermes/scripts/ulak_apply.sh

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
