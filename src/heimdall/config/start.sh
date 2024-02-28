#!/bin/bash
# Initialise the Heimdall configuration and genesis file before starting the validator node.

# Generate dummy configuration files (including genesis).
heimdalld init --chain-id "{{.CHAIN_ID}}" --home "{{.DATA_PATH}}"

# Format the validator private key.
heimdallcli generate-validatorkey --home "{{.DATA_PATH}}" "{{.VALIDATOR_NODE_PRIVATE_KEY}}"

# Generate the final genesis file.
heimdalld init --chain-id "{{.CHAIN_ID}}" --home "{{.DATA_PATH}}" --id "{{.NODE_ID}}" --overwrite-genesis

# Start the validator node.
heimdalld start --all --amqp_url "{{.RABBITMQ_AMQP_URL}}" --bridge --rest-server
