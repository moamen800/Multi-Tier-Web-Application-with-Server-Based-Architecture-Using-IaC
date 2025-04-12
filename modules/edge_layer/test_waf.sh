#!/bin/bash

URL="http://d31rym9me7qce2.cloudfront.net"
TOTAL_REQUESTS=100
BLOCK_COUNT=0

for ((i=1; i<=TOTAL_REQUESTS; i++))
do
  # Add a dynamic query string to bust cache
  FULL_URL="$URL?nocache=$(date +%s%N)"

  STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$FULL_URL")

  echo "Request $i: Status Code = $STATUS_CODE"

  if [ "$STATUS_CODE" -eq 403 ]; then
    ((BLOCK_COUNT++))
    echo "🚫 Blocked by WAF (403)"
  fi

  sleep 0.01  # fast, but not instant to allow WAF count aggregation
done

echo -e "\nSummary: Sent $TOTAL_REQUESTS requests, Blocked: $BLOCK_COUNT"
