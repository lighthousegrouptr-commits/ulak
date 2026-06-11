Session observations (2026-06-11):
- Dokploy containers observed: dokploy-traefik (Traefik reverse proxy), dokploy (Dokploy app), dokploy-postgres, dokploy-redis, plus several application containers (anadolu-terra-frontend, lighthousegoup-web-*, synthetic-intelligence, hermetic-agenticos, musikapp).
- /etc/dokploy directory structure present with subdirectories: applications, compose, logs, monitoring, schedules, ssh, traefik, volume-backups.
- Both /etc/dokploy/volume-backups and /etc/dokploy/schedules were empty (no backup files or schedule files found).
- No cron jobs related to dokploy or backup found in /etc/cron* or user crontab (only a refresh-agentic-data job).
- Dokploy API likely runs on port 3000 (node process listening on 127.0.0.1:3000) but not tested for a backup endpoint.
- No explicit dokploy backup service or container identified; backup functionality may be internal to Dokploy app or rely on external configuration.
- Suggested next steps: check Dokploy UI for backup settings, verify if backup configuration exists in Dokploy database or config files, consider setting up a backup schedule via Dokploy's scheduling feature or external cron.