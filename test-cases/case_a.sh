#!/bin/bash

#### Test Name: TransferRequest
#### Test Goal: Test TransferRequest endpoint and inits a Transfer Process. Assert initiation of transfer process

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
# We create a TransferRequestMessage
providerPid=$(
    curl --location 'http://127.0.0.1:1234/transfers/request' \
        --header 'Content-Type: application/json' \
        --data-raw '{
            "@context": [
                "https://w3id.org/dspace/2025/1/context.jsonld"
            ],
            "@type": "TransferRequestMessage",
            "consumerPid": "urn:uuid:aa24a275-31c0-aafe-a097-2f9caf895dac",
            "agreementId": "urn:uuid:6149fdf7-325c-48f7-a626-06a416a023ba",
            "format": "http+pull",
            "callbackAddress": ""
        }' | jq -r '.providerPid'
)

# We test the state of the Transfer
expected_state="REQUESTED"
state=$(
    curl --location "http://127.0.0.1:1234/transfers/$providerPid" | jq -r '.state'
)

# Assertions
if [ "$state" != "$expected_state" ]; then
    echo "Assertion failed: expected state '$expected_state' but got '$state'"
    exit 1
fi
echo "✅ Assertion passed: state is '$state'"
#### END TEST

#### BEGIN POSTAMBLE
docker compose -f ./ds-deployment/docker-compose.yaml down
#### END PREAMBLE