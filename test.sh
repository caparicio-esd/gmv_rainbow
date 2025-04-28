#!/bin/bash

# create a subscription
curl -X POST \
    http://127.0.0.1:1234/api/v1/transfers/subscriptions \
    -H "Content-Type: application/json" \
    -d '{
        "callbackAddress": "http://localhost:1111/hola"
    }'

# {
#     "subscriptionId": "urn:uuid:f4d0f324-fc2a-42b4-83e0-013d63c3152b",
#     "callbackAddress": "http://localhost:1111/hola",
#     "timestamp": "2025-04-28T09:58:15.056852",
#     "expirationTime": null,
#     "subscriptionEntity": "TransferProcess",
#     "active": true
# }


# fetch all subscriptions
curl http://127.0.0.1:1234/api/v1/transfers/subscriptions

# [
#   {
#     "subscriptionId":"urn:uuid:f4d0f324-fc2a-42b4-83e0-013d63c3152b",
#     "callbackAddress":"http://localhost:1111/hola",
#     "timestamp":"2025-04-28T09:58:15.056852",
#     "expirationTime":null,
#     "subscriptionEntity":"TransferProcess",
#     "active":true
#   },
#   {
#     "subscriptionId":"urn:uuid:8158de81-9fb9-4d7a-9236-7f3c4d756c67",
#     "callbackAddress":"http://localhost:1111/hola",
#     "timestamp":"2025-04-28T09:59:38.461714",
#     "expirationTime":null,
#     "subscriptionEntity":"TransferProcess",
#     "active":true
#   },
#   {
#     "subscriptionId":"urn:uuid:4ac7508e-051b-4a2f-b481-e71a42073b9b",
#     "callbackAddress":"http://localhost:1111/hola",
#     "timestamp":"2025-04-28T09:59:39.359062",
#     "expirationTime":null,
#     "subscriptionEntity":"TransferProcess",
#     "active":true
#   }
# ]