#### Test Name: Create a New Catalog
#### Test Goal: Use Catalog API to create a new catalog and assert the creation

#### BEGIN PREAMBLE
# Run dbs
# Setup provider and consumer dbs
# Setup servers consumer and provider
#### END PREAMBLE

#### BEGIN TEST
# We create a Catalog with HTTP request to http://127.0.0.1:1234/api/v1/catalogs
# We extract body and http code
# Assert http code is 201
#### END TEST

#### BEGIN POSTAMBLE
# Tear down dbs and servers
#### END POSTAMBLE