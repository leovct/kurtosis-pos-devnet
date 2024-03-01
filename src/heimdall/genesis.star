def generate_slashing_infos(validator_count):
    slashing_infos = {}
    for id in range(validator_count):
        slashing_infos[str(id)] = {
            "valID": str(id),
            "startHeight": "0",
            "indexOffset": "0",
        }
    return slashing_infos


def generate_validators(validator_count, validator_keys):
    validators = []
    for id in range(validator_count):
        hex_full_public_key = validator_keys[id]["full_public_key"]
        eth_address = validator_keys[id]["eth_address"]
        validator = {
            "ID": str(id),
            "startEpoch": "0",
            "endEpoch": "0",
            "nonce": "1",
            "power": "10000",
            "pubKey": "0x04{}".format(hex_full_public_key),
            "signer": eth_address,
            "last_updated": "",
            "jailed": json.encode(False), # TODO: Remove quotes?
            "accum": "0",
        }
        validators.append(validator)
    return validators


def generate_dividend(validator_count, validator_keys):
    dividends = []
    for id in range(validator_count):
        eth_address = validator_keys[id]["eth_address"]
        dividend = {"user": eth_address, "feeAmount": "0"}
        dividends.append(dividend)
    return dividends


def generate_accounts(validator_count, validator_keys):
    accounts = []
    for id in range(validator_count):
        eth_address = validator_keys[id]["eth_address"]
        account = {
            "address": eth_address,
            "coins": [{"denom": "matic", "amount": "1000000000000000000000"}],
            "sequence_number": "0",
            "account_number": "0",
            "module_name": "",
            "module_permissions": json.encode(None),  # TODO: Remove quotes?
        }
        accounts.append(account)
    return accounts
