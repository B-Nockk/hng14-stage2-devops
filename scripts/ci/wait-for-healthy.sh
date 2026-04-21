#!/usr/bin/env bash
set -euo pipefail

CONTAINER="stage2-frontend-1"
TIMEOUT=90

echo "Waiting for ${CONTAINER} to be healthy (timeout: ${TIMEOUT}s)..."

timeout "${TIMEOUT}" bash -c "
  until [ \"\$(docker inspect --format='{{.State.Health.Status}}' ${CONTAINER} 2>/dev/null)\" = \"healthy\" ]; do
    echo '  still waiting...'
    sleep 5
  done
"

echo "Stack is healthy."
