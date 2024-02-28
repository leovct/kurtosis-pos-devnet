bor_module = import_module("./src/bor/main.star")
heimdall_module = import_module("./src/heimdall/main.star")
rootchain_module = import_module("./src/rootchain/main.star")
file_utils = import_module("./src/utils/file.star")
service_utils = import_module("./src/utils/service.star")
validator_keys_generator_module = import_module(
    "./src/validator-keys-generator/main.star"
)


def run(plan, validators, mnemonic, rootchain):
    plan.print("validators: {}, mnemonic: {}".format(validators, mnemonic))

    # Generate validator keys.
    # TODO: Remove most of the logic from the script and only generate keys.json with polycli.
    validator_keys_path = "/etc/validators"
    validator_keys = validator_keys_generator_module.run(
        plan, validators, mnemonic, validator_keys_path
    )

    # Start the rootchain.
    # TODO: Add an option to deploy the rootchain or or simply specify the url.
    # If the rootchain needs to be deployed, also deploy pos contracts on it.
    plan.print("rootchain: {}".format(rootchain))
    rootchain_rpc_url = rootchain_module.run(plan, mnemonic, rootchain)

    # Generate bor genesis.
    bor_genesis = bor_module.generate_bor_genesis(plan, validator_keys)

    # Start a number of heimdall and bor nodes.
    heimdall_nodes_ip_addresses = {}
    bor_nodes_ip_addresses = {}
    heimdall_static_peers = []
    bor_static_nodes = []
    for id in range(1, validators + 1):
        validator_private_key = file_utils.extract_json_key_with_jq(
            plan,
            "validator-keys-generator",
            "{}/keys.json".format(validator_keys_path),
            ".Addresses[{}].HexPrivateKey".format(id - 1),
        )
        validator_address = file_utils.read_file_content(
            plan,
            "validator-keys-generator",
            "{}/validator_{}/address.txt".format(validator_keys_path, id),
        )
        bor_node_public_key = file_utils.extract_json_key_with_jq(
            plan,
            "validator-keys-generator",
            "{}/validator_{}/nodekey.json".format(validator_keys_path, id),
            ".PublicKey",
        )

        heimdall_node_ip_address = heimdall_module.run(
            plan, id, validator_private_key, rootchain_rpc_url
        )
        heimdall_node_id = file_utils.extract_json_key_without_jq(
            plan,
            "heimdall-{}".format(id),
            "/root/.heimdalld/node_id.json",
            ".node_id",
        )
        plan.print(heimdall_node_id)
        heimdall_static_peer_address = get_heimdall_static_peer_address(
            heimdall_node_id, heimdall_node_ip_address
        )
        heimdall_static_peers.append(heimdall_static_peer_address)

        bor_node_ip_address = bor_module.run(
            plan,
            id,
            validator_keys,
            validator_address,
            bor_genesis,
            heimdall_node_ip_address,
            validator_keys_path,
        )
        bor_nodes_ip_addresses[id] = bor_node_ip_address
        bor_static_node_address = get_bor_static_node_address(
            bor_node_ip_address, bor_node_public_key
        )
        bor_static_nodes.append(bor_static_node_address)

    # Update bor static nodes.
    heimdall_static_peers_string = ",".join(heimdall_static_peers)
    plan.print(heimdall_static_peers)
    plan.print(heimdall_static_peers_string)
    plan.print(bor_static_nodes)

    for id in range(1, validators + 1):
        # Adjust the config given the randomly generated ip addresses.
        bor_node_ip_address = bor_nodes_ip_addresses[id]
        heimdall_module.replace_bor_rpc_url_in_config(plan, id, bor_node_ip_address)
        heimdall_module.replace_static_peers_in_config(
            plan, id, heimdall_static_peers_string
        )
        service_utils.restart_service(plan, "heimdall-{}".format(id))

    # for i in range(1, validators + 1):
    #    bor_service_name = "bor-{}".format(i)
    #    bor_config = bor_module.generate_bor_config(
    #        plan,
    #        id,
    #        bor_service_name,
    #        validator_address,
    #        heimdall_node_ip_address,
    #        validator_keys_path,
    #    )
    #
    #    bor_data_path = "/etc/bor"
    #    update_bor_static_nodes(plan, bor_service_name, bor_data_path, bor_static_nodes)


def get_bor_static_node_address(ip_address, public_key):
    return "enode://{}@{}:30303".format(public_key, ip_address)


def get_heimdall_static_peer_address(node_id, ip_address):
    # TODO: Provision an old docker devnet and find out what's the format
    return "{}@{}:26656".format(node_id, ip_address)
