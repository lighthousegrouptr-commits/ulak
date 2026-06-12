# Sentry DSN Verification via curl

Given a DSN like:
```
https://e108bffa3f930bb5903f331013c644ed@o4511552738689024.ingest.de.sentry.io/4511552882409552
```

Extract:
- Public key: `e108bffa3f930bb5903f331013c644ed`
- Org ID: `4511552738689024`
- Region: `de` (from ingest.de.sentry.io)
- Project ID: `4511552882409552`

Store endpoint:
```
https://o4511552738689024.ingest.de.sentry.io/api/4511552882409552/store/
```

Minimal test event (adjust timestamp):
```bash
ts=$(date +%s)
curl -s -o /dev/null -w "%{http_code}" -X POST "https://o4511552738689024.ingest.de.sentry.io/api/4511552882409552/store/" \
  -H "Content-Type: application/json" \
  -H "Sentry: sentry_key=e108bffa3f930bb5903f331013c644ed, sentry_version=7, sentry_client=hulak/1.0, sentry_timestamp=$ts" \
  -d '{"event_id":"test123","timestamp":'$ts',"level":"error","message":"test from sentry-integration skill"}'
```

Expected output: `200` (or `200 OK` if you follow with `-i`).

If you receive `401`, verify:
- Timestamp is recent (within a few minutes).
- Public key matches the DSN.
- Region is correct (e.g., `ingest.de.sentry.io`).
- No extra whitespace in headers.
