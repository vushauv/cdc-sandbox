#!/usr/bin/env bash
set -euo pipefail
topic="${1:-dbserver1.inventory.customers}"
docker compose exec kafka /kafka/bin/kafka-console-consumer.sh \
  --bootstrap-server kafka:9092 \
  --topic "$topic" \
  --from-beginning
