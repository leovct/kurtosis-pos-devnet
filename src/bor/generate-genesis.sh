#!/bin/bash -ex
# Generate Bor genesis file.

echo "Processing templates..."
cd /opt/genesis-contracts/matic-contracts || exit
node scripts/process-templates.js --bor-chain-id "{{.BOR_CHAIN_ID}}"

echo; echo "Compiling matic-contracts..."
npm run truffle:compile

echo; echo "Copying the list of validators..."
cd /opt/genesis-contracts || exit
cp "{{.VAlIDATOR_KEYS_PATH}}"/validators.js /opt/genesis-contracts/validators.js
cat /opt/genesis-contracts/validators.js

echo; echo "Generating validator set contract..."
node generate-borvalidatorset.js --bor-chain-id "{{.BOR_CHAIN_ID}}" --heimdall-chain-id "{{.HEIMDALL_CHAIN_ID}}"

echo; echo "Generating genesis file..."
node generate-genesis.js --bor-chain-id "{{.BOR_CHAIN_ID}}" --heimdall-chain-id "{{.HEIMDALL_CHAIN_ID}}"
mkdir -p "{{.GENESIS_FOLDER}}"
cp /opt/genesis-contracts/genesis.json "{{.GENESIS_FOLDER}}/genesis.json"
cat "{{.GENESIS_FOLDER}}/genesis.json"

touch /tmp/done
echo; echo "Done generating genesis file!"
sleep 10
