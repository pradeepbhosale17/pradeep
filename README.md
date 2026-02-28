# StreamingData-Debezium

Simple scaffold for a Debezium-powered CDC proof‑of‑concept (PoC).

This repository helps you stand up a local environment with Kafka, Schema Registry,
Debezium Connect, and a PostgreSQL source database.  It demonstrates
*streaming table changes* and handling **schema evolution** via Confluent
Schema Registry.

---

## Prerequisites

* Docker & Docker Compose 1.29+ (Linux/macOS/Windows)
* `curl` (for connector REST calls)

> All commands in this README assume you are running them from the
> `StreamingData-Debezium` directory.

## Quick start

1. Start the stack:

   ```sh
   # run the helper with bash so pipefail/etc work correctly
   bash ./scripts/setup.sh
   ```
   The script autodetects either `docker-compose` or the newer `docker compose`
   CLI. If neither is present you’ll be prompted to install Docker Compose.

   ### Installing Docker Compose

   * **Docker Desktop (macOS/Windows):** Compose is bundled; make sure it's
     enabled in settings, or update to the latest version.
   * **Linux:**
     ```sh
     # older versions (standalone binary):
     sudo curl -L "https://github.com/docker/compose/releases/download/2.18.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
     sudo chmod +x /usr/local/bin/docker-compose
     
     # newer CLI plugin (recommended):
     sudo apt-get install docker-compose-plugin   # Debian/Ubuntu
     # or
     sudo yum install docker-compose-plugin      # RHEL/Fedora/CentOS
     # use it via: docker compose
     ```
     
     * **WSL / Windows users:** install **Docker Desktop for Windows**
       with WSL2 integration enabled.  Compose comes bundled; after
       installation make sure the `docker` command is available within your
       WSL distro (`docker version` should succeed).  You don’t need to install
       anything inside WSL specifically; the `docker compose` CLI will be
       forwarded to the Desktop engine.
   * **Verify availability:**
     ```sh
     docker-compose --version   # or
     docker compose version
     ```
   Services:
   * **Postgres** with an `inventory.customers` table and a couple of rows
     (see `init.sql`).
   * **Zookeeper** ➜ **Kafka** broker on `localhost:9092`.
   * **Schema Registry** on `http://localhost:8081`.
   * **Kafka Connect** (Debezium image) on `http://localhost:8083`.

2. Verify PostgreSQL is ready:

   ```sh
   docker exec -it $(docker-compose ps -q postgres) psql \
     -U postgres -d inventory -c "SELECT * FROM customers;"
   ```

3. Deploy the Debezium connector:

   ```sh
   curl -X POST -H "Content-Type: application/json" \
     --data @connect/postgres-connector.json \
     http://localhost:8083/connectors
   ```

   The connector configuration lives under `connect/postgres-connector.json`.
   It streams changes from `public.customers` and writes Avro-serialized
   records to the topic `dbserver1.public.customers` using Schema Registry.

3. Consume the change events

   * **CLI (quick):**
     ```sh
     docker exec -it $(docker-compose ps -q kafka) \
       kafka-avro-console-consumer \
       --bootstrap-server kafka:9092 \
       --topic dbserver1.public.customers \
       --from-beginning \
       --property schema.registry.url=http://schema-registry:8081
     ```

     You should see two records corresponding to the rows inserted by `init.sql`.

   * **Python example:** install requirements and run the provided script:
     ```sh
     pip install "confluent-kafka[avro]"
     python consumer.py
     ```

## Schema evolution demo

1. Add a new column and insert a row with that column populated:

   ```sh
   docker exec -i $(docker-compose ps -q postgres) psql \
     -U postgres -d inventory < evolve.sql
   ```

2. Observe the consumer output: the third record will include an additional
   `email` field.  Schema Registry will have stored a new schema version for
   `dbserver1.public.customers` that includes the extra column.

3. (Optional) Inspect the schema versions:

   ```sh
   curl http://localhost:8081/subjects/dbserver1.public.customers-value/versions
   ```

   The response lists the evolution of the Avro schema; you can fetch a
   specific version via `/versions/{n}`.

## Cleaning up

To tear down the environment:

```sh
docker-compose down -v
```

This removes containers and the Postgres volume, letting you start fresh.

---

🎯 **What you just built**
* A working CDC pipeline using Debezium (Postgres connector).
* Events serialized as Avro and registered with Schema Registry.
* Demonstrated schema evolution when the source table is altered.

Use this scaffold as a basis for a more advanced streaming project or to
experiment with connectors, transformation SMTs, or different converters.
