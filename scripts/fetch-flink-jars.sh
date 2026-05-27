#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p flink-lib
jar=flink-sql-connector-kafka-3.2.0-1.18.jar
if [[ ! -f flink-lib/$jar ]]; then
  curl -L -o flink-lib/$jar \
    https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-kafka/3.2.0-1.18/$jar
fi
ls -la flink-lib/
