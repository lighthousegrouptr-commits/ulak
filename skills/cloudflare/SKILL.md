---
name: cloudflare
description: "Configure and manage Cloudflare settings via API (cache, DNS, SSL, etc.)"
version: 1.0.0
author: Ulak Agent
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [cloudflare, api, dns, cache, security]
---

# Cloudflare Configuration Skill

This skill provides reusable procedures for managing Cloudflare resources using the Cloudflare API v4.
It assumes you have an API token with appropriate permissions (Zone:Settings:Edit, Zone:Cache Purge, DNS:Edit, etc.)
and know your Zone ID.

## Prerequisites

- Cloudflare API Token (create via My Profile → API Tokens → Custom token)
- Zone ID for the domain (found in Overview → API section)
- `curl` and `jq` (optional for pretty output)

## Environment Variables (optional but recommended)

Set these in your shell or `.env` to avoid repeating values:

```bash
export CF_ZONE_ID="your-zone-id-here"
export CF_TOKEN="your-token-here"
```

Then you can use `${CF_ZONE_ID}` and `${CF_TOKEN}` in the commands below.

## Common Operations

### 1. Verify API Token

```bash
curl -s "https://api.cloudflare.com/client/v4/user/tokens/verify" \
     -H "Authorization: Bearer ${CF_TOKEN}" \
     -H "Content-Type: application/json" | jq .
```

Should return `{"success":true,"result":{"status":"active"}, ...}`

### 2. Get Zone ID (if you don't have it)

```bash
curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=example.com" \
     -H "Authorization: Bearer ${CF_TOKEN}" \
     -H "Content-Type: application/json" | jq .
```

Look for the object with `"name":"example.com"` and copy its `"id"`.

### 3. Configure Browser Cache TTL

Sets how long browsers should cache static assets (value in seconds).

```bash
curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/settings/browser_cache_ttl" \
     -H "Authorization: Bearer ${CF_TOKEN}" \
     -H "Content-Type: application/json" \
     --data '{"value":86400}'   # 1 day (86400s)
```

### 4. Configure Edge Cache TTL

Sets how long Cloudflare edge servers cache content (value in seconds).

```bash
curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/settings/cache_ttl" \
     -H "Authorization: Bearer ${CF_TOKEN}" \
     -H "Content-Type: application/json" \
     --data '{"value":7200}'   # 2 hours
```

### 5. Set Cache Level

Controls how aggressively Cloudflare caches content.

Valid values: `off`, `basic`, `standard`, `aggressive`.

```bash
curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/settings/cache_level" \
     -H "Authorization: Bearer ${CF_TOKEN}" \
     -H "Content-Type: application/json" \
     --data '{"value":"aggressive"}'
```

### 6. Toggle Development Mode

Bypasses cache temporarily (max 3 hours). Useful while developing.

```bash
# Enable
curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/settings/development_mode" \
     -H "Authorization: Bearer ${CF_TOKEN}" \
     -H "Content-Type: application/json" \
     --data '{"value":"on"}'

# Disable (or wait 3 hours for auto-off)
curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/settings/development_mode" \
     -H "Authorization: Bearer ${CF_TOKEN}" \
     -H "Content-Type: application/json" \
     --data '{"value":"off"}'
```

### 7. Always Online

Serves a static copy of your site when the origin is offline.

```bash
curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/settings/always_online" \
     -H "Authorization: Bearer ${CF_TOKEN}" \
     -H "Content-Type: application/json" \
     --data '{"value":"on"}'
```

### 8. Purge Cache

- Purge everything:

```bash
curl -s -X POST "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/purge_cache" \
     -H "Authorization: Bearer ${CF_TOKEN}" \
     -H "Content-Type: application/json" \
     --data '{"purge_everything":true}'
```

- Purge specific files (tags):

```bash
curl -s -X POST "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/purge_cache" \
     -H "Authorization: Bearer ${CF_TOKEN}" \
     -H "Content-Type: application/json" \
     --data '{"files":["https://example.com/style.css","https://example.com/script.js"]}'
```

### 9. List DNS Records

```bash
curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/dns_records" \
     -H "Authorization: Bearer ${CF_TOKEN}" \
     -H "Content-Type: application/json" | jq .
```

### 10. Create DNS Record (example: A record)

```bash
curl -s -X POST "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/dns_records" \
     -H "Authorization: Bearer ${CF_TOKEN}" \
     -H "Content-Type: application/json" \
     --data '{"type":"A","name":"www","content":"192.0.2.1","ttl":1,"proxied":true}'
```

## Tips & Pitfalls

- **API Token Scope**: Give only the permissions you need. Over‑scoped tokens increase risk if leaked.
- **Rate Limits**: Cloudflare allows 1,200 requests per 5 minutes per token. Batch changes when possible.
- **Propagation**: Changes to DNS or settings may take a few seconds to a minute to propagate globally.
- **Development Mode**: Remember it automatically turns off after 3 hours; if you need longer, schedule a cron job to re‑enable it.
- **Cache Level "aggressive"**: May cache HTML that you expect to be dynamic; test thoroughly.
- **Always Online**: Only works for static sites; dynamic applications may show outdated content.

## Verification

After making changes, you can verify the live values:

```bash
# Example: check browser_cache_ttl
curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/settings/browser_cache_ttl" \
     -H "Authorization: Bearer ${CF_TOKEN}" \
     -H "Content-Type: application/json" | jq .
```

## Automation

Store the commands in a script and run them via Hermes `terminal()` or a cron job for routine maintenance.

Example helper script (`~/scripts/cloudflare-settings.sh`):

```bash
#!/usr/bin/env bash
set -euo pipefail

ZONE_ID="${CF_ZONE_ID:-}"
TOKEN="${CF_TOKEN:-}"

if [[ -z "$ZONE_ID" || -z "$TOKEN" ]]; then
  echo "Error: Set CF_ZONE_ID and CF_TOKEN environment variables" >&2
  exit 1
fi

patch() {
  local path="$1"
  local data="$2"
  curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/settings/${path}" \
       -H "Authorization: Bearer ${TOKEN}" \
       -H "Content-Type: application/json" \
       --data "${data}"
}

# Apply settings
patch browser_cache_ttl    '{"value":86400}'
patch cache_ttl            '{"value":7200}'
patch cache_level          '{"value":"aggressive"}'
patch development_mode     '{"value":"off"}'
patch always_online        '{"value":"on"}'

echo "Cloudflare settings applied."
```

Make it executable and run as needed.

## References

- Official API docs: https://api.cloudflare.com/
- Rate limits: https://developers.cloudflare.com/api/rate-limits/
- Zone settings reference: https://developers.cloudflare.com/api/operations/zone-settings-get-zone-setting

## Related Skills

- `hermes-agent`: For general Hermes configuration and setup.
- `seo-audit`: For checking SEO impact of Cloudflare changes (e.g., caching, always online).

---