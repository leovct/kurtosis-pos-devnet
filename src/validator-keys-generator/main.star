service_utils = import_module("../utils/service.star")

SERVICE_NAME = "validator-keys-generator"
DATA_PATH = "/etc/keys"


def run(plan, validator_count, mnemonic):
    return _start_validator_keys_generator(plan, validator_count, mnemonic)


def _start_validator_keys_generator(plan, validator_count, mnemonic):
    ready_condition = service_utils.define_completion_file_ready_condition()
    plan.add_service(
        name=SERVICE_NAME,
        config=ServiceConfig(
            image=ImageBuildSpec(image_name=SERVICE_NAME, build_context_dir="."),
            env_vars={
                "VALIDATOR_COUNT": "{}".format(validator_count),
                "MNEMONIC": mnemonic,
                "DATA_PATH": DATA_PATH,
            },
            ready_conditions=ready_condition,
        ),
    )
    artifact = plan.store_service_files(
        service_name=SERVICE_NAME, src="{}/*".format(DATA_PATH), name="validator-keys"
    )
    validator_keys = get_validator_keys(plan, validator_count)
    plan.remove_service(SERVICE_NAME)
    return artifact, validator_keys


def get_validator_keys(plan, validator_count):
    keys = {}
    for id in range(validator_count):
        eth_address = _extract_validator_key(plan, id, "ETHAddress")
        public_key = _extract_validator_key(plan, id, "HexPublicKey")
        private_key = _extract_validator_key(plan, id, "HexPrivateKey")
        bor_p2p_public_key = _extract_p2p_node_key(plan, id, "PublicKey")
        keys[id] = {
            "eth_address": eth_address,
            "public_key": public_key,
            "private_key": private_key,
            "bor_p2p_public_key": bor_p2p_public_key,
        }
    return keys


def _extract_validator_key(plan, id, key):
    return service_utils.extract_json_key_from_service_with_jq(
        plan,
        SERVICE_NAME,
        "{}/keys.json".format(DATA_PATH),
        ".Addresses[{}].{}".format(id, key),
    )


def _extract_p2p_node_key(plan, id, key):
    return service_utils.extract_json_key_from_service_with_jq(
        plan,
        SERVICE_NAME,
        "{}/validator_{}/nodekey.json".format(DATA_PATH, id),
        ".{}".format(key),
    )
