#!/usr/bin/env bash
set -euo pipefail

# Find the actual frontend container (handles different naming conventions)
CONTAINER=$(docker ps -a --filter "name=frontend" --format "{{.Names}}" | head -1)
TIMEOUT=90

if [ -z "$CONTAINER" ]; then
    echo "Error: No frontend container found!"
    exit 1
fi

echo "Waiting for ${CONTAINER} to be healthy (timeout: ${TIMEOUT}s)..."

timeout "${TIMEOUT}" bash -c "
  until [ \"\$(docker inspect --format='{{.State.Health.Status}}' ${CONTAINER} 2>/dev/null)\" = \"healthy\" ]; do
    echo '  still waiting...'
    sleep 5
  done
"

echo "Stack is healthy."
