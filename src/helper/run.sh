#!/bin/bash
# Generate validators keys.

# Generate keys.
mkdir "$DATA_PATH"
polycli wallet inspect --addresses "$VALIDATORS_COUNT" --mnemonic "$MNEMONIC" > "$DATA_PATH/keys.json"
echo "Validator keys generated!"
cat "$DATA_PATH/keys.json"

# Extract keys for each validator.
for i in $(seq 0 $((VALIDATORS_COUNT - 1))); do
  jq -r ".Addresses[$i] | .HexPrivateKey" < "$DATA_PATH/keys.json" > "$DATA_PATH/validator_$((i + 1)).key"
  echo; echo "Key extracted for validator #$((i + 1))!"
  cat "$DATA_PATH/validator_$((i + 1)).key"
done

touch /tmp/done
echo; echo "Done generating keys!"
