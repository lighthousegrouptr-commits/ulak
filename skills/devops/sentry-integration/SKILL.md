---
name: sentry-integration
description: Integrate Sentry error monitoring, verify DSN connectivity, and send test events.
triggers:
  - sentry
  - dsn
  - monitoring
---

# Sentry Integration Skill

## Description
Integrate Sentry error monitoring into applications, verify DSN connectivity, and send test events.

## When to Use
- Setting up Sentry for a new project
- Verifying that a Sentry DSN is correctly configured
- Sending a test event to ensure connectivity

## Steps

1. **Add DSN to Environment**
   - For Docker/Kubernetes: add `SENTRY_DSN=<your_dsn>` to your container env or pod spec.
   - For VM/bare metal: export `SENTRY_DSN` or add to `.env` file.
   - Example DSN format: `https://<public_key>@o<org_id>.ingest.<region>.sentry.io/<project_id>`

2. **Verify DSN Connectivity**
   - Use `curl` with proper Sentry header to POST a test event to the store endpoint.
   - Extract the endpoint from DSN: `https://o<org_id>.ingest.<region>.sentry.io/api/<project_id>/store/`
   - Required headers:
     - `Content-Type: application/json`
     - `Sentry: sentry_key=<public_key>, sentry_version=7, sentry_client=<client_name>/<version>, sentry_timestamp=<unix_ts>`
   - JSON payload (minimal):
     ```json
     {
       "event_id": "<uuid>",
       "timestamp": <unix_ts>,
       "level": "error",
       "message": "test from sentry-integration skill"
     }
     ```
   - Example command:
     ```bash
     ts=$(date +%s)
     curl -s -o /dev/null -w "%{http_code}" -X POST "https://o4511552738689024.ingest.de.sentry.io/api/4511552882409552/store/" \
       -H "Content-Type: application/json" \
       -H "Sentry: sentry_key=e108bffa3f930bb5903f331013c644ed, sentry_version=7, sentry_client=hulak/1.0, sentry_timestamp=$ts" \
       -d '{"event_id":"test123","timestamp":'$ts',"level":"error","message":"test from ulak"}'
     ```
   - Expect HTTP 200 OK on success. 401 indicates authentication issue (check DSN parts, timestamp, or missing secret key if required).

3. **Using sentry-cli (if available)**
   - Install: `npm i -g @sentry/cli` or follow https://docs.sentry.io/product/cli/
   - Configure: `sentry-cli login` (requires auth token) or set `SENTRY_ORG`, `SENTRY_PROJECT`, `SENTRY_AUTH_TOKEN`.
   - Test: `sentry-cli test-event`

4. **Check Events in Sentry UI**
   - After sending, navigate to your Sentry project → Issues to see the test event.

## Pitfalls
- **Timestamp must be recent**: Sentry rejects events with timestamps too far in the past or future. Use current unix seconds.
- **Header format**: Must include `sentry_key` (public key from DSN), `sentry_version=7`, `sentry_client`, and `sentry_timestamp`.
- **DSN vs. endpoint**: The store endpoint is not the DSN; append `/api/<project_id>/store/` to the ingest URL.
- **401 errors**: Double-check that the public key matches the project, and that you are using the correct region (e.g., `ingest.de.sentry.io`).
- **No secret key needed**: For pure event ingestion, only the DSN public part is used; the secret part is not required in the header.

## Verification
- Successful test returns HTTP 200 and a JSON response containing an `id` matching the sent event_id.
- If you see 401, verify the DSN components and try again with a fresh timestamp.

## References
- See `references/sentry-curl-example.md` for a ready-to-run example.
- See `scripts/test-sentry.sh` for a reusable verification script.