#!/usr/bin/env bash
set -euo pipefail

FRONTEND_URL="http://localhost:3000"
TIMEOUT_SECONDS=30

echo "Submitting job..."
RESPONSE=$(curl -sf -X POST "${FRONTEND_URL}/submit")
JOB_ID=$(echo "${RESPONSE}" | python3 -c "import sys,json; print(json.load(sys.stdin)['job_id'])")
echo "Submitted job: ${JOB_ID}"

echo "Polling for completion (timeout: ${TIMEOUT_SECONDS}s)..."
DEADLINE=$((SECONDS + TIMEOUT_SECONDS))

while [ $SECONDS -lt $DEADLINE ]; do
  STATUS=$(curl -sf "${FRONTEND_URL}/status/${JOB_ID}" \
    | python3 -c "import sys,json; print(json.load(sys.stdin)['status'])")
  echo "  status: ${STATUS}"

  if [ "${STATUS}" = "completed" ]; then
    echo "Job completed successfully."
    exit 0
  fi

  sleep 2
done

echo "ERROR: Job ${JOB_ID} did not complete within ${TIMEOUT_SECONDS} seconds."
exit 1
