---
name: hermes-config-backup
description: "Backup, sync, and customize Hermes agent identity (persona/branding): SOUL.md, WhatsApp bridge, config.yaml, cli.py, GitHub sync, and post-update rebrand automation."
version: 2.0.0
author: Ulak Agent
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [hermes, ulak, backup, github, sync, whatsapp, persona, branding, identity]
---

# Hermes Config Backup & Persona Customization

This skill covers two related workflows:

1. **Persona/Identity Customization** — Renaming and rebranding the Hermes agent instance via SOUL.md, WhatsApp bridge, config.yaml, and cli.py.
2. **Config Backup & Sync** — Backing up all Hermes config, memories, skills, and cron jobs to GitHub, with automatic post-update re-application.

---

## Section 1: Persona Customization

### 1A. SOUL.md — Identity Slot

`~/.hermes/SOUL.md` is the **identity slot** — injected as the very first block of the system prompt on every turn. Editing it changes the agent's name, personality, or tone.

Changes are **loaded fresh each message** — no restart needed for CLI sessions.
For gateway (WhatsApp, Telegram, etc.): run `hermes gateway restart` to apply immediately.

`load_soul_md()` in `agent/prompt_builder.py` reads this file and places it as slot #1 (the "identity" block) in the system prompt.

```bash
cat > ~/.hermes/SOUL.md << 'EOF'
# Ulak Agent Persona

Sen Ulak'sın — terminal tabanlı, hızlı ve güvenilir bir AI asistan.
EOF
```

**Profiles**: Each profile has its own SOUL.md at `~/.hermes/profiles/<name>/SOUL.md`. Editing the default profile's file won't affect other profiles.
**Not found on fresh install?** Just create it — the file may not exist.

### 1B. WhatsApp Bridge — Prefix & Browser Identity

SOUL.md alone does NOT rename the WhatsApp message prefix. Patch `bridge.js`:

```bash
BRIDGE="/usr/local/lib/hermes-agent/scripts/whatsapp-bridge/bridge.js"
sed -i "s/⚕ \*Hermes Agent\*/⚕ *Ulak Agent*/g" "$BRIDGE"
sed -i "s/browser: \['Hermes Agent'/browser: ['Ulak Agent'/g" "$BRIDGE"
grep -n "Ulak Agent" "$BRIDGE"
```

**Update-resistant alternative**: Set `WHATSAPP_REPLY_PREFIX` in `~/.hermes/.env`:
```
WHATSAPP_REPLY_PREFIX=⚕ *Ulak Agent*\n────────────\n
```

### 1C. config.yaml — Personality Names

```bash
sed -i "s/Captain Hermes/Captain Ulak/g" ~/.hermes/config.yaml
sed -i "s/They call me Hermes/They call me Ulak/g" ~/.hermes/config.yaml
```

Config changes require gateway restart.

### 1D. cli.py — Banner, Logo, Agent Name

`hermes update` resets `cli.py`. Five areas need updating:
- `HERMES_AGENT_LOGO` (multi-line string — use Python `patch()`, not `sed`)
- `HERMES_CADUCEUS` (same — use Lighthouse Group ASCII art, see `references/lighthouse-caduceus.md`)
- Banner text (`⚕ NOUS HERMES` → `⚕ ULAK`)
- `agent_name` default (`"Hermes Agent"` → `"Ulak Agent"`)
- Status bar fallback (`'Hermes'` → `'Ulak'`)

Use `ulak_apply.sh` (Section 2E) for the full rebrand in one shot.

### 1E. Persona Pitfalls

- **Current session shows old name**: Change takes effect from next message (gateway: after restart).
- **`patch` tool blocked on bridge.js** — use `sed -i` directly.
- **WhatsApp self-chat mode**: Only messages from your own number are processed; others are rejected.
- **Slash commands**: New commands must be added to `COMMAND_REGISTRY` in `hermes_cli/commands.py` and handled in `cli.py`.

---

## Section 2: Config Backup & GitHub Sync

### Trigger Conditions

- After `hermes update`
- After gateway restart if WhatsApp prefix reverted
- New server setup
- Manual invocation

### 2A. What to Back Up

| Source | Destination in `/root/ulak/` | Notes |
|--------|------------------------------|-------|
| `~/.hermes/SOUL.md` | `SOUL.md` | Persona identity |
| `~/.hermes/memories/*.md` | `memories/` | Agent memory files |
| `~/.hermes/skills/` | `skills/` | All skills (rsync with `--delete`) |
| `~/.hermes/cron/jobs.json` | `cron/jobs.json` | Cron job definitions |
| `~/.hermes/config.yaml` | `config/config.yaml` | Secrets stripped via `grep -v` |
| `~/.hermes/hooks/` | `hooks/` | If non-empty |
| `~/.hermes/scripts/` | `scripts/` | Includes ulak_sync.sh itself |

### 2B. Secrets Filtering

config.yaml is copied with secrets stripped:
```bash
grep -v "api_key\|password\|secret\|token\|TOKEN\|SECRET\|PASSWORD" \
  "$HERMES/config.yaml" > "$ULAK/config/config.yaml"
```

### 2C. GitHub Remote

- HTTPS remote with embedded token: `https://$GITHUB_TOKEN@github.com/OWNER/REPO.git`
- Token read from `~/.hermes/.env` as `GITHUB_TOKEN`
- Repo: `/root/ulak` → `github.com/lighthousegrouptr-commits/ulak`

### 2D. Sync Script

`scripts/ulak_sync.sh` handles the full backup + git commit + push. See `references/sync-script.md` for the complete script.

### 2E. Full Rebrand Script (ulak_apply.sh)

After `hermes update`, re-apply all customizations in one shot:

```bash
#!/bin/bash
# Save to ~/.hermes/scripts/ulak_apply.sh and chmod +x
hermes update && bash ~/.hermes/scripts/ulak_apply.sh
```

The script: updates SOUL.md → patches bridge.js → updates config.yaml → restarts gateway.

### 2F. Backup Pitfalls

- `hermes update` resets both `bridge.js` and `cli.py` — always run `ulak_apply.sh` after updating
- `HERMES_AGENT_LOGO` and `HERMES_CADUCEUS` are multi-line strings — `sed` cannot replace them; use Python `patch()`
- Gateway restart does NOT require QR scan — session is preserved at `~/.hermes/whatsapp/session`

---

## Reference Files

- `references/lighthouse-caduceus.md` — ASCII art for Lighthouse Group favicon logo
- `references/sync-script.md` — Full `ulak_sync.sh` script reference

## Scripts

- `scripts/ulak_sync.sh` — Config backup & GitHub sync script
