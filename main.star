rootchain_module = import_module("./src/rootchain.star")
heimdall_module = import_module("./src/heimdall/heimdall.star")


def run(plan, validators, mnemonic, rootchain):
    # Print arguments.
    plan.print("mnemnonic: {}".format(mnemonic))
    plan.print("rootchain: {}".format(rootchain))

    # Start the rootchain.
    rootchain_rpc_url = rootchain_module.run(plan, mnemonic, rootchain)

    # Start a number of heimdall nodes.
    bor_rpc_url = "http://localhost:8545"
    for i in range(1, validators + 1):
        heimdall_module.run(
            plan, i, rootchain_rpc_url, bor_rpc_url, mnemonic, validators
        )
