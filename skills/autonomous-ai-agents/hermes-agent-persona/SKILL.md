---
name: hermes-agent-persona
description: "Customize the Hermes Agent identity: name, persona, tone, and branding via SOUL.md."
version: 1.0.0
author: agent
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [hermes, persona, identity, customization, branding, soul]
    related_skills: [hermes-agent]
---

# Hermes Agent Persona Customization

How to rename, rebrand, or change the personality of the Hermes Agent instance.

## The Key File

```
~/.hermes/SOUL.md
```

This is the **identity slot** — it is injected as the very first block of the system prompt on every turn. Editing it is all you need to change the agent's name, personality, or tone.

Changes are **loaded fresh each message** — no restart needed for CLI sessions.

For gateway (WhatsApp, Telegram, etc.): run `hermes gateway restart` to apply immediately to the running service.

## Minimal Example

```markdown
# Ulak Agent Persona

Sen Ulak'sın — terminal tabanlı, hızlı ve güvenilir bir AI asistan.
```

## Full Template

```markdown
# <YourAgentName> Persona

<!--
This file defines the agent's personality and tone.
Edit this to customize how <YourAgentName> communicates with you.
Delete the contents (or this file) to use the default personality.
-->

<One-sentence identity statement here.>
```

## Steps to Rename

1. Open the file:
   ```bash
   nano ~/.hermes/SOUL.md
   # or: hermes config edit  (opens full config.yaml, not SOUL.md — use nano/vim directly)
   ```
2. Replace the `# Hermes Agent Persona` heading and any internal references with your preferred name.
3. Save the file.
4. For **CLI**: change takes effect on the next message automatically.
5. For **gateway**: `hermes gateway restart`

## How It Works (Internal)

`load_soul_md()` in `agent/prompt_builder.py` reads `~/.hermes/SOUL.md` and places it as slot #1 in the assembled system prompt (the "identity" block). The rest of the system prompt (skills index, platform hints, memory, etc.) follows after it.

The default file is written by the install script (`scripts/install.sh` / `install.ps1`) with the heading `# Hermes Agent Persona`. Overwriting SOUL.md fully replaces that default.

## Pitfalls

- **Current session still shows old name**: the running session loaded the old SOUL.md at start. The change shows from the *next* message onward (gateway: after restart).
- **SOUL.md not found**: the file may not exist yet on fresh installs that skipped the wizard. Just create it at `~/.hermes/SOUL.md`.
- **Profiles**: each profile has its own SOUL.md at `~/.hermes/profiles/<name>/SOUL.md`. Editing the default profile's file won't affect other profiles.
