# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo actually is

This repo is **not** the agent's source code — it's a sanitized, auto-synced snapshot of the live Hermes Agent home directory (`~/.hermes/`), pushed to GitHub every 30 minutes so Lighthouse Group has a versioned backup of agent configuration, skills, memory, and cron jobs.

The actual Hermes Agent runtime lives at `/usr/local/lib/hermes-agent/` (Python — `cli.py`, gateway, WhatsApp bridge at `scripts/whatsapp-bridge/bridge.js`). The user's live config and state live at `~/.hermes/`. This repo mirrors a subset of `~/.hermes/` to git.

"Ulak" is a Lighthouse Group rebrand of "Hermes" — same agent, different persona/name.

## Three-way data flow

```
~/.hermes/        ──ulak_sync.sh (cron every 30m)──>  /root/ulak/  ──git push──>  github.com/lighthousegrouptr-commits/ulak
   (live)                                              (snapshot)                    (backup)

/usr/local/lib/hermes-agent/   <──ulak_apply.sh──   (re-stamps Hermes→Ulak branding after `hermes update`)
   (installed code)
```

- `scripts/ulak_sync.sh` — runs every 30 min via cron job `925ecf983b1d` (defined in `cron/jobs.json`). Copies `SOUL.md`, `memories/`, `skills/`, `cron/jobs.json`, hooks, and a **secret-filtered** `config.yaml` from `~/.hermes/` into this repo, then commits with message `sync: YYYY-MM-DD HH:MM` and pushes.
- `scripts/ulak_apply.sh` — run **manually after `hermes update`**. Re-applies the Ulak brand by `sed`-patching the freshly reinstalled `/usr/local/lib/hermes-agent/cli.py`, `bridge.js`, and `~/.hermes/config.yaml` (replaces "Hermes" → "Ulak" in banner, agent_name, status bar, persona strings), then restarts the gateway.

## Critical rules when editing

- **Do not edit `SOUL.md`, `memories/*.md`, `skills/`, `cron/jobs.json`, or `config/config.yaml` in this repo directly** — they are overwritten on every sync from `~/.hermes/`. Edit the source in `~/.hermes/` instead.
- **Edits to `scripts/ulak_sync.sh` in this repo do not take effect** — the cron job runs `~/.hermes/scripts/ulak_sync.sh`. The sync script copies itself back into the repo at the end (`cp $HERMES/scripts/ulak_sync.sh $ULAK/scripts/ulak_sync.sh`), so the repo copy is a mirror, not the runtime. To change sync behavior, edit `~/.hermes/scripts/ulak_sync.sh`.
- `config/config.yaml` here has secrets stripped — `ulak_sync.sh` greps out lines matching `api_key|password|secret|token|TOKEN|SECRET|PASSWORD` before committing. Never restore secrets to the committed file.
- The git remote URL in `.git/config` contains a personal access token. Don't echo it into commits, issues, or chat.

## Commands

| Task | Command |
| --- | --- |
| Manual sync now | `bash ~/.hermes/scripts/ulak_sync.sh` |
| Re-apply Ulak branding after `hermes update` | `hermes update && bash ~/.hermes/scripts/ulak_apply.sh` |
| Inspect / manage the sync cron job | `hermes cron list` / `hermes cron show 925ecf983b1d` |
| Check sync status | `cd /root/ulak && git log --oneline -5` |

## User context

- User: Levent Şane (Lighthouse Group). Communicates primarily via WhatsApp.
- WhatsApp does not render markdown — when replying through the WhatsApp channel, use plain text, no `**bold**`, no headings.
- Default reply language for this user is **Turkish**. Code, comments, and commit messages in this repo are a mix of Turkish and English — match the surrounding file.
- Agent identity must remain "Ulak", not "Hermes" — `ulak_apply.sh` exists specifically to re-enforce this after updates.
