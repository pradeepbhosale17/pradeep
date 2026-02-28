#!/usr/bin/env bash

# run the evolution SQL against postgres container

docker exec -i $(docker-compose ps -q postgres) psql \
  -U postgres -d inventory < evolve.sql

echo "schema evolved (email column added) and new row inserted."
