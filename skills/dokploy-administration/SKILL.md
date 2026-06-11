---
name: dokploy-administration
description: Verify Dokploy service health and backup configuration.
category: devops
---
# Dokploy Administration

This skill provides steps to verify Dokploy service health, backup configuration, and troubleshoot common issues.

## Trigger
- User asks to check Dokploy backup service.
- User wants to verify Dokploy is running correctly.
- User suspects backup service missing.

## Steps
1. List Dokploy-related containers: `docker ps --filter "name=dokploy" --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"`
2. Check Traefik (reverse proxy) container: `docker ps --filter "name=dokploy-traefik"`
3. Inspect Dokploy configuration directory: `ls -la /etc/dokploy`
4. Look for backup directories: `ls -la /etc/dokploy/volume-backups` and `/etc/dokploy/schedules`
5. Check for backup cron jobs: `grep -r backup /etc/cron*` and `crontab -l`
6. Verify Dokploy API (if exposed) by curling localhost:3000 (or appropriate port) and checking for a `/api/health` or similar endpoint.
7. Review logs: `ls -la /etc/dokploy/logs` and check recent log files.
8. If any containers are down, restart them: `docker start <container>` or `docker-compose up -d` depending on deployment.
9. Ensure volume backups exist: check for recent tarballs or snapshots in `/etc/dokploy/volume-backups`.
10. If missing, consult Dokploy documentation for backup setup.

## Pitfalls
- Assuming Dokploy runs as a single container; it may be split into multiple services (traefik, api, redis, postgres).
- Backup cron may be set up via Dokploy's internal scheduler, not system cron.
- The Dokploy API may only be accessible locally; use `curl http://127.0.0.1:3000/api/status` (adjust port).
- Lack of backups in `/etc/dokploy/volume-backups` does not mean backups aren't happening; they may be stored elsewhere (e.g., remote S3).

## Verification
- After steps, confirm that Dokploy containers are Up, configuration directories exist, and backup schedules are present.
- If user reports missing backup service, advise to check Dokploy backup configuration in the Dokploy UI or `dokploy backup` CLI if available.

## References
- Dokploy official docs: https://docs.dokploy.com
- Example backup command: `dokploy backup create`
