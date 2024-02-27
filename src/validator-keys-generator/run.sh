#!/bin/bash
# Generate validators keys.

# Generate keys.
mkdir "$DATA_PATH"
polycli wallet inspect --addresses "$VALIDATORS_COUNT" --mnemonic "$MNEMONIC" > "$DATA_PATH/keys.json"
echo "Validator keys generated!"
echo "\`\`\`json"; cat "$DATA_PATH/keys.json"; echo "\`\`\`"

# Extract address and key for each validator.
for i in $(seq 0 $((VALIDATORS_COUNT - 1))); do
  mkdir "$DATA_PATH/validator_$((i + 1))"

  jq -r ".Addresses[$i]" < "$DATA_PATH/keys.json" | jq > "$DATA_PATH/validator_$((i + 1))/key.json"
  echo; echo "Key extracted for validator #$((i + 1))!"
  echo "\`\`\`json"; cat "$DATA_PATH/validator_$((i + 1))/key.json"; echo "\`\`\`"

  # Required to set up heimdall.
  hex_private_key="$(jq -r ".HexPrivateKey" < "$DATA_PATH/validator_$((i + 1))/key.json")"
  echo -n "$hex_private_key" > "$DATA_PATH/validator_$((i + 1))/key.txt"

  # Required to set up bor.
  jq -r ".Addresses[$i] | .ETHAddress" < "$DATA_PATH/keys.json" | tr -d "\n" > "$DATA_PATH/validator_$((i + 1))/address.txt"
  echo; echo "Address extracted for validator #$((i + 1))!"
  cat "$DATA_PATH/validator_$((i + 1))/address.txt"

  mkdir "$DATA_PATH/validator_$((i + 1))/keystore"
  polycli parseethwallet --hexkey "$hex_private_key" --keystore "$DATA_PATH/validator_$((i + 1))/keystore"
  echo; echo "Keystore created for validator #$((i + 1))!"
  ls "$DATA_PATH/validator_$((i + 1))/keystore"

  polycli nodekey | jq -r '.PrivateKey' > "$DATA_PATH/validator_$((i + 1))/bor_nodekey"
  echo; echo "Bor node key created for validator #$((i + 1))!"
  cat "$DATA_PATH/validator_$((i + 1))/bor_nodekey"
done

# Generate the list of validators, required to create bor genesis file.
printf "const validators = [\n%s\n];\n\nexports = module.exports = validators;\n" "$(jq -r '.Addresses[] | { address: .ETHAddress, stake: 100, balance: 1000000 }' < "$DATA_PATH/keys.json" | sed 's/\}/\},/g' | sed 's/^/    /')" > "$DATA_PATH/validators.js"
echo; echo "Done generating the validators list"
echo "\`\`\`typescript"; cat "$DATA_PATH/validators.js"; echo "\`\`\`"

touch /tmp/done
echo; echo "Done generating keys!"
sleep infinity
