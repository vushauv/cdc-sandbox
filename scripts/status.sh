#!/usr/bin/env bash
set -euo pipefail
curl -sS http://localhost:8083/connectors/inventory-connector/status | jq .
