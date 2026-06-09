---
name: traefik-basic-auth
description: Manage basic auth users in Traefik middleware files (typically under /etc/dokploy/traefik/dynamic/middlewares.yml).
category: devops
---

# Traefik Basic Auth Management

## Overview
Traefik can protect endpoints using basic auth middleware. The user list is stored in a middleware file, commonly `middlewares.yml` in a Dokploy/TRAEFIK setup.

## When to Use
- Need to reset or change a basic auth password for a service behind Traefik.
- Adding or removing users.

## Steps

### 1. Locate the middleware file
Typical path: `/etc/dokploy/traefik/dynamic/middlewares.yml`
If using a different setup, find the file referenced in the Traefik dynamic configuration for the router.

### 2. View current users
```bash
sudo cat /etc/dokploy/traefik/dynamic/middlewares.yml
```
Look for the `hermes-auth` (or relevant) middleware block:
```yaml
hermes-auth:
  basicAuth:
    users:
      - admin:$apr1$...
```

### 3. Generate a new password hash
Use `openssl passwd -apr1` to create an apr1-md5 hash:
```bash
PASSWORD=your_new_password
HASH=$(openssl passwd -apr1 "$PASSWORD")
echo "$HASH"
```
Alternatively, let the skill generate a random password:
```bash
PASSWORD=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c16)
HASH=$(openssl passwd -apr1 "$PASSWORD")
echo "Password: $PASSWORD"
echo "Hash: $HASH"
```

### 4. Update the middleware file
Replace the hash for the desired user (e.g., admin) using `sed`:
```bash
sudo sed -i 's/- admin:\$apr1\$[^\$]*\$[^\$]*/- admin:$apr1$SALT$HASH/' /etc/dokploy/traefik/dynamic/middlewares.yml
```
Replace `SALT$HASH` with the generated hash (including the `$apr1$` prefix). Example:
```bash
sudo sed -i 's/- admin:\$apr1\$1VCeL1rd\$UQE74LtovK8kbX0YhHOHk1/- admin:\$apr1\$zQtR5p48\$cdba3B2hMTfGlW4E8d0Ot0/' /etc/dokploy/traefik/dynamic/middlewares.yml
```

### 5. Verify the change
```bash
sudo grep -A2 'hermes-auth:' /etc/dokploy/traefik/dynamic/middlewares.yml
```
Confirm the new hash appears.

### 6. Reload Traefik (if needed)
In most Dokploy setups, Traefik detects file changes automatically. To force a reload:
```bash
sudo systemctl restart traefik   # if using systemd
# or, if Traefik runs as a container:
docker restart traefik
```

## Pitfalls
- The hash must be apr1-md5 format (`$apr1$...`). Using other formats will cause auth failure.
- Ensure the line you replace is unique; otherwise, use more context in the sed pattern.
- After updating, clear browser cache or use incognito to test, as browsers may cache basic auth credentials.
- If the middleware file is managed by a configuration automation tool (e.g., ansible, dokploy), manual edits may be overwritten. Prefer updating via the source of truth.

## Verification
After updating, try accessing the protected URL with the new credentials:
```bash
curl -u admin:new_password https://hermes.lighthousegroup.net.tr/
```
Should return a 200 (or the application's response) instead of 401.

## References
- Traefik basic auth middleware: https://doc.traefik.io/traefik/middlewares/basicauth/
- OpenSSL passwd apr1: https://www.openssl.org/docs/man1.1.1/man1/openssl-passwd.html