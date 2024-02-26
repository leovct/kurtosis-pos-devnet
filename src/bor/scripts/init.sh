#!/bin/bash
# Generate Bor genesis file.

echo "Processing templates..."
cd /opt/genesis-contracts/matic-contracts || exit
node scripts/process-templates.js --bor-chain-id "{{.BOR_CHAIN_ID}}"
npm run truffle:compile

echo "Generating validator set..."
cd /opt/genesis-contracts || exit
# TODO: fix that
polycli wallet inspect --mnemonic "{{.MNEMONIC}}" --addresses "{{.VALIDATORS}}" > /data/keys.json
printf "const validators = [\n%s\n];\n\nexports = module.exports = validators;\n" "$(jq -r '.Addresses[] | { address: .ETHAddress, stake: 100, balance: 1000000 }' < /data/keys.json | sed 's/\}/\},/g' | sed 's/^/    /')" > validators.js
node generate-borvalidatorset.js --bor-chain-id "{{.BOR_CHAIN_ID}}" --heimdall-chain-id "{{.HEIMDALL_CHAIN_ID}}"

echo "Generating genesis file..."
node generate-genesis.js --bor-chain-id "{{.BOR_CHAIN_ID}}" --heimdall-chain-id "{{.HEIMDALL_CHAIN_ID}}"
