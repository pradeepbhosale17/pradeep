#!/usr/bin/env bash

# ensure we're running under bash (some systems link /bin/sh to dash)
if [ -z "${BASH_VERSION:-}" ]; then
    exec bash "$0" "$@"
fi

set -euo pipefail

# determine docker compose command (support new and old naming)
if command -v docker-compose >/dev/null 2>&1; then
    dc_cmd=docker-compose
elif docker compose version >/dev/null 2>&1; then
    dc_cmd="docker compose"
else
    echo "error: neither 'docker-compose' nor 'docker compose' is available; please install Docker Compose" >&2
    exit 1
fi

# bring up the entire stack
$dc_cmd up -d

echo "waiting for Postgres to be ready..."
until docker exec -i $(docker-compose ps -q postgres) pg_isready -U postgres; do
  sleep 1
done

echo "registering Debezium connector"
curl -X POST -H "Content-Type: application/json" \
  --data @connect/postgres-connector.json \
  http://localhost:8083/connectors

echo "done. consumer command:" 
cat <<'EOF'
docker exec -it $(docker-compose ps -q kafka) \
  kafka-avro-console-consumer \
  --bootstrap-server kafka:9092 \
  --topic dbserver1.public.customers \
  --from-beginning \
  --property schema.registry.url=http://schema-registry:8081
EOF
