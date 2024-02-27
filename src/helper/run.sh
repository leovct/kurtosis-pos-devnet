#!/bin/bash
# Generate validators keys.

# Generate keys.
mkdir "$DATA_PATH"
polycli wallet inspect --addresses "$VALIDATORS_COUNT" --mnemonic "$MNEMONIC" > "$DATA_PATH/keys.json"
echo "Validator keys generated!"
echo "\`\`\`json"; cat "$DATA_PATH/keys.json"; echo "\`\`\`"

# Extract address and key for each validator.
for i in $(seq 0 $((VALIDATORS_COUNT - 1))); do
  mkdir validator_$((i + 1))

  jq -r ".Addresses[$i] | .ETHAddress" < "$DATA_PATH/keys.json" > "$DATA_PATH/validator_$((i + 1))/address.txt"
  echo; echo "Address extracted for validator #$((i + 1))!"
  cat "$DATA_PATH/validator_$((i + 1))/address.txt"

  jq -r ".Addresses[$i] | .HexPrivateKey" < "$DATA_PATH/keys.json" > "$DATA_PATH/validator_$((i + 1))/key.txt"
  echo; echo "Key extracted for validator #$((i + 1))!"
  cat "$DATA_PATH/validator_$((i + 1))/key.txt"
done

# Generate the list of validators, required to create bor genesis file.
printf "const validators = [\n%s\n];\n\nexports = module.exports = validators;\n" "$(jq -r '.Addresses[] | { address: .ETHAddress, stake: 100, balance: 1000000 }' < "$DATA_PATH/keys.json" | sed 's/\}/\},/g' | sed 's/^/    /')" > "$DATA_PATH/validators.js"
echo; echo "Done generating the validators list"
echo "\`\`\`typescript"; cat "$DATA_PATH/validators.js"; echo "\`\`\`"

touch /tmp/done
echo; echo "Done generating keys!"
sleep 10
