#!/bin/bash
# Generate Heimdall genesis file and start the validator node.

# Generate dummy configuration files (including genesis).
heimdalld init --chain-id {{.CHAIN_ID}} --home {{.DATA_PATH}}

# Generate the validator private key.
polycli wallet inspect --addresses {{.VALIDATORS_COUNT}} --mnemonic '{{.MNEMONIC}}' | jq -r '.Addresses[{{.NODE_ID}}] | .HexPrivateKey' > {{.DATA_PATH}}/data/private_key.txt
pushd {{.DATA_PATH}}/config
heimdallcli generate-validatorkey --home . "$(cat ../data/private_key.txt)"

# Generate the final genesis file.
heimdalld init --chain-id {{.CHAIN_ID}} --home {{.DATA_PATH}} --id {{.NODE_ID}} --overwrite-genesis

# Start the validator node.
# TODO: Is it necessary to specify --all and also --bridge?
heimdalld start --all --amqp_url {{.AMQP_URL}} --bridge --rest-server
