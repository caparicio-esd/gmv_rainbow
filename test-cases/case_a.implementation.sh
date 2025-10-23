#!/bin/bash

#### Test Name: TransferRequest
#### Test Goal: Test TransferRequest endpoint and inits a Transfer Process. Assert initiation of transfer process

#### BEGIN PREAMBLE
# Run dbs and services in scripts/bash/auto-*.sh
#### END PREAMBLE

#### BEGIN TEST
# We create a TransferRequestMessage with HTTP REST API
providerPid=$(
    curl --location 'http://127.0.0.1:1200/transfers/setup-start' \
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

# We test the state field of the Transfer
expected_state="REQUESTED"
state=$(
    curl --location "http://127.0.0.1:1200/transfers/$providerPid" | jq -r '.state'
)

# We assert state==REQUESTED
if [ "$state" != "$expected_state" ]; then
    echo "Assertion failed: expected state '$expected_state' but got '$state'"
    exit 1
fi
echo "✅ Assertion passed: state is '$state'"
#### END TEST

#### BEGIN POSTAMBLE
docker compose -f ./ds-deployment/docker-compose.yaml down
#### END POSTAMBLE