bor_module = import_module("./src/bor/bor.star")
heimdall_module = import_module("./src/heimdall/heimdall.star")
helper_module = import_module("./src/helper/helper.star")
rootchain_module = import_module("./src/rootchain/rootchain.star")


def run(plan, validators, mnemonic, rootchain):
    plan.print("validators: {}, mnemonic: {}".format(validators, mnemonic))

    # Generate validator keys.
    validator_keys = helper_module.run(plan, validators, mnemonic)

    # Start the rootchain.
    plan.print("rootchain: {}".format(rootchain))
    rootchain_rpc_url = rootchain_module.run(plan, mnemonic, rootchain)

    # Generate bor genesis.
    bor_genesis = bor_module.generate_bor_genesis(plan, validator_keys)

    # Start a number of heimdall and bor nodes.
    bor_rpc_url = "http://localhost:8545"  # TODO: change me
    for i in range(1, validators + 1):
        heimdall_module.run(plan, i, validator_keys, rootchain_rpc_url, bor_rpc_url)
        bor_module.run(plan, i, validator_keys, bor_genesis)
