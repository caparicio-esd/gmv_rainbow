#!/bin/bash

#### Test Name: Create a New Catalog
#### Test Goal: Use Catalog API to create a new catalog and assert the creation

#### BEGIN PREAMBLE
# Run dbs
docker compose -f ./ds-deployment/docker-compose.yaml up -d db-provider db-consumer
sleep 3
# Setup provider and consumer dbs
docker compose -f ./ds-deployment/docker-compose.yaml up ds-provider-setup ds-consumer-setup
sleep 2
# Setup servers consumer and provider
docker compose -f ./ds-deployment/docker-compose.yaml up -d ds-provider ds-consumer
sleep 1
#### END PREAMBLE

#### BEGIN TEST
# We create a Catalog
response=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" \
  --location 'http://127.0.0.1:1234/api/v1/catalogs' \
  --header 'Content-Type: application/json' \
  --data '{
    "foaf:homepage": "catalog homepage",
    "dct:title": "catalog title"
  }')

echo $response

# We extract body and http code
body=$(echo "$response" | sed -e 's/HTTPSTATUS\:.*//g') # Get response but HTTPSTATUS onwards
http_code=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://') # Get response HTTPSTATUS onwards

# Assert http code is a number
if ! [[ "$http_code" =~ ^[0-9]+$ ]]; then
  echo "Error: HTTP code [$http_code] is not a number"
  exit 1
fi

# Assert http code is 201
if [ "$http_code" -ne 201 ]; then
  echo "Assertion failed: expected 201, got $http_code"
  echo "Response body:"
  echo "$body"
  exit 1
fi

echo "✅ HTTP $http_code OK"
echo "$body" | jq
#### END TEST

#### BEGIN POSTAMBLE
docker compose -f ./ds-deployment/docker-compose.yaml down
#### END PREAMBLE