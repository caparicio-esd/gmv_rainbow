#!/bin/bash

# Run dbs
docker compose -f ./ds-deployment/docker-compose.yaml up -d db-provider db-consumer
sleep 10

# Setup provider and consumer dbs
docker compose -f ./ds-deployment/docker-compose.yaml up ds-provider-setup ds-consumer-setup
sleep 5

# Setup servers consumer and provider
docker compose -f ./ds-deployment/docker-compose.yaml up ds-provider ds-consumer