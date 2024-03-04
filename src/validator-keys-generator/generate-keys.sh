#!/bin/bash
# Generate validators keys.

# Generate validator keys.
mkdir "$DATA_PATH"
polycli wallet inspect --addresses "$VALIDATOR_COUNT" --mnemonic "$MNEMONIC" > "$DATA_PATH/keys.json"
echo "Validator keys generated!"
echo "\`\`\`json"; cat "$DATA_PATH/keys.json"; echo "\`\`\`"

# Setting up bor keys.
for i in $(seq 0 $((VALIDATOR_COUNT - 1))); do
  # Generate bor keystore.
  mkdir -p "$DATA_PATH/validator_$i/keystore"
  hex_private_key="$(jq -r ".Addresses[$i].HexPrivateKey" < "$DATA_PATH/keys.json")"
  polycli parseethwallet --hexkey "$hex_private_key" --keystore "$DATA_PATH/validator_$i/keystore"
  echo; echo "Keystore created for validator #$i!"
  ls "$DATA_PATH/validator_$i/keystore"

  # Generate bor node p2p key.
  polycli nodekey | jq > "$DATA_PATH/validator_$i/nodekey.json"
  jq -r ".PrivateKey" "$DATA_PATH/validator_$i/nodekey.json" > "$DATA_PATH/validator_$i/nodekey.key"
  echo; echo "Bor node key created for validator #$i!"
  cat "$DATA_PATH/validator_$i/nodekey.json"
done

# Generate the list of validators, required to create bor genesis file.
printf "const validators = [\n%s\n];\n\nexports = module.exports = validators;\n" "$(jq -r '.Addresses[] | { address: .ETHAddress, stake: 100, balance: 1000000 }' < "$DATA_PATH/keys.json" | sed 's/\}/\},/g' | sed 's/^/    /')" > "$DATA_PATH/validators.js"
echo; echo "Done generating the validators list"
echo "\`\`\`typescript"; cat "$DATA_PATH/validators.js"; echo "\`\`\`"

touch /tmp/done
echo; echo "Done generating keys!"
sleep infinity
