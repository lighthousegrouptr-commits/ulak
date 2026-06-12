#!/usr/bin/env bash
# test-sentry.sh: Verify Sentry DSN connectivity by sending a test event.
#
# Usage: ./test-sentry.sh <DSN>
# Example: ./test-sentry.sh "https://e108bffa3f930bb5903f331013c644ed@o4511552738689024.ingest.de.sentry.io/4511552882409552"
#
# Requires: curl, date, grep, awk (optional)
#
# Returns HTTP status code; 200 indicates success.

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <DSN>" >&2
  exit 1
fi

DSN="$1"

# Parse DSN: https://<public>@o<org>.ingest.<region>.sentry.io/<project>
if [[ ! "$DSN" =~ ^https://([^@]+)@o([0-9]+)\\.ingest\\.([^.]+)\\.sentry\\.io/([0-9]+)$ ]]; then
  echo "Invalid DSN format. Expected: https://<public>@o<org>.ingest.<region>.sentry.io/<project>" >&2
  exit 2
fi

PUBLIC_KEY="${BASH_REMATCH[1]}"
ORG_ID="${BASH_REMATCH[2]}"
REGION="${BASH_REMATCH[3]}"
PROJECT_ID="${BASH_REMATCH[4]}"

ENDPOINT="https://o${ORG_ID}.ingest.${REGION}.sentry.io/api/${PROJECT_ID}/store/"
TIMESTAMP=$(date +%s)
EVENT_ID="test-$(date +%s%N)"  # nanoseconds for uniqueness

PAYLOAD=$(cat <<EOF
{
  "event_id": "$EVENT_ID",
  "timestamp": $TIMESTAMP,
  "level": "error",
  "message": "test from sentry-integration skill script"
}
EOF
)

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$ENDPOINT" \
  -H "Content-Type: application/json" \
  -H "Sentry: sentry_key=${PUBLIC_KEY}, sentry_version=7, sentry_client=test-sentry/1.0, sentry_timestamp=${TIMESTAMP}" \
  -d "$PAYLOAD")

echo "HTTP $HTTP_CODE"
if [[ "$HTTP_CODE" == "200" ]]; then
  echo "Sentry test event sent successfully."
  exit 0
else
  echo "Failed to send test event. Check DSN, network, and timestamp."
  exit 1
fi