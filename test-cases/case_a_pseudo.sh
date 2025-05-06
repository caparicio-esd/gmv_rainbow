#### Test Name: TransferRequest
#### Test Goal: Test TransferRequest endpoint and inits a Transfer Process. Assert initiation of transfer process

#### BEGIN PREAMBLE
# Run dbs
# Setup provider and consumer dbs
# Setup servers consumer and provider
#### END PREAMBLE

#### BEGIN TEST
# We create a TransferRequestMessage with HTTP REST API
# We test the state field of the Transfer
# We assert state==REQUESTED
#### END TEST

#### BEGIN POSTAMBLE
# Tear down dbs and servers
#### END POSTAMBLE