#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
curl -sS -X POST -H "Content-Type: application/json" \
  --data @register-postgres.json \
  http://localhost:8083/connectors | jq .
