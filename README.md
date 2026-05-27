# CDC sandbox

Lab project. Postgres -> Debezium -> Kafka -> Flink SQL, all in docker compose.

## Diagram

(drawn separately)

## Run

```bash
cp .env.example .env
cp secrets.properties.example secrets.properties
./scripts/fetch-flink-jars.sh    # downloads Kafka SQL connector into flink-lib/
docker compose up -d
```

Wait ~20s for Connect to be ready, then:

```bash
./scripts/register.sh        # register Debezium source connector
./scripts/status.sh          # should print RUNNING
./scripts/consume.sh         # tail customers topic
```

Mutate source DB in another terminali or with a GUI:

```bash
docker compose exec postgres psql -U postgres -d postgres
```
```sql
UPDATE inventory.customers SET first_name='X' WHERE id=1001;
INSERT INTO inventory.customers VALUES (1010,'A','B','a@b.c');
DELETE FROM inventory.customers WHERE id=1010;
```

Watch consumer print events.

## Flink

```bash
docker compose exec flink-jobmanager ./bin/sql-client.sh
```

```sql
SET 'sql-client.execution.result-mode' = 'tableau';

CREATE TABLE customers (
  id INT,
  first_name STRING,
  last_name STRING,
  email STRING,
  PRIMARY KEY (id) NOT ENFORCED
) WITH (
  'connector' = 'kafka',
  'topic' = 'dbserver1.inventory.customers',
  'properties.bootstrap.servers' = 'kafka:9092',
  'properties.group.id' = 'flink-demo',
  'scan.startup.mode' = 'earliest-offset',
  'format' = 'debezium-json',
  'debezium-json.schema-include' = 'true'
);

SELECT last_name, COUNT(*) FROM customers GROUP BY last_name;
```

Insert in Postgres, watch count update.

Flink UI: http://localhost:8081

## What each piece does

- **postgres** — source DB. `wal_level=logical` set in image. Preloaded
  `inventory` schema (customers, orders, products).
- **kafka** — log/transport. Topics auto-created as `<prefix>.<schema>.<table>`.
- **connect** — Kafka Connect worker hosting Debezium. Reads Postgres WAL
  via `pgoutput`, emits `{op, before, after, source.{lsn,ts_ms}, ts_ms}`.
- **flink-jobmanager / flink-taskmanager** — stream processor. `debezium-json`
  format converts CDC envelope to Flink changelog (`+I/-U/+U/-D`) so
  aggregations stay correct on update/delete.

## Secrets

`POSTGRES_*` and `DEBEZIUM_VERSION` come from `.env` (compose substitution,
container env). Connector password resolved at runtime by Connect's
`FileConfigProvider` from `secrets.properties` — same pattern as Key Vault
