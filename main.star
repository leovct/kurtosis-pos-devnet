bor_module = import_module("./src/bor/main.star")
heimdall_module = import_module("./src/heimdall/heimdall.star")
rootchain_module = import_module("./src/rootchain/ganache.star")
service_utils = import_module("./src/utils/service.star")
validator_keys_generator_module = import_module(
    "./src/validator-keys-generator/main.star"
)


def run(plan, validator_count, mnemonic, rootchain_rpc_url="", rootchain={}):
    # Generate validator keys.
    plan.print(
        "Generating keys for {} validators using menmonic: {}".format(
            validator_count, mnemonic
        )
    )
    keys_artifact, validator_keys = validator_keys_generator_module.run(
        plan, validator_count, mnemonic
    )
    plan.print("Keys generated: {}".format(validator_keys))

    # Start the rootchain if `rootchain_rpc_url` has not been specified.
    if rootchain_rpc_url != "":
        plan.print("Using {} as rootchain RPC URL".format(rootchain_rpc_url))
    else:
        plan.print(
            "Deploying a custom root chain with parameters: {}".format(rootchain)
        )
        # TODO: Remove harcoded BOR_CHAIN_ID value.
        rootchain_rpc_url = rootchain_module.run(
            plan, validator_count, rootchain, mnemonic, "137", validator_keys
        )
        plan.print("Custom rootchain RPC URL: {}".format(rootchain_rpc_url))

    # Generate bor genesis.
    plan.print("Generating bor genesis")
    bor_genesis = bor_module.generate_bor_genesis(plan, keys_artifact)

    # Start a number of heimdall and bor nodes.
    heimdall_nodes_ip_addresses = {}
    bor_nodes_ip_addresses = {}
    heimdall_static_peers = []
    bor_static_nodes = []
    for id in range(validator_count):
        plan.print("Starting validator node {}".format(id))
        validator_eth_address = validator_keys[id]["eth_address"]
        validator_private_key = validator_keys[id]["private_key"]
        validator_bor_p2p_public_key = validator_keys[id]["bor_p2p_public_key"]

        # Start Heimdall node.
        heimdall_node_ip_address = heimdall_module.run(
            plan, id, validator_private_key, rootchain_rpc_url
        )
        heimdall_node_p2p_address = heimdall_module.get_heimdall_static_peer_address(
            plan, id, heimdall_node_ip_address
        )
        heimdall_static_peers.append(heimdall_node_p2p_address)

        # Start Bor node.
        bor_node_ip_address = bor_module.run(
            plan,
            id,
            validator_eth_address,
            heimdall_node_ip_address,
            keys_artifact,
            bor_genesis,
        )
        bor_nodes_ip_addresses[id] = bor_node_ip_address
        bor_static_node_address = get_bor_static_node_address(
            bor_node_ip_address, validator_bor_p2p_public_key
        )
        bor_static_nodes.append(bor_static_node_address)

    for id in range(validator_count):
        # Adjust the config given the randomly generated ip addresses.
        heimdall_static_peers_updated = (
            heimdall_static_peers[:id] + heimdall_static_peers[id + 1 :]
        )
        heimdall_static_peers_string = ",".join(heimdall_static_peers_updated)

        bor_node_ip_address = bor_nodes_ip_addresses[id]
        heimdall_module.update_config_and_restart(
            plan, id, bor_node_ip_address, heimdall_static_peers_string
        )
        # bor_module.update_config_and_restart(plan, id, bor_static_nodes)


def get_bor_static_node_address(ip_address, public_key):
    return "enode://{}@{}:30303".format(public_key, ip_address)
