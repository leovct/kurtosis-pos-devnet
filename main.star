rootchain = import_module("./src/rootchain.star")
heimdall = import_module("./src/heimdall/heimdall.star")

MNEMONIC = "code code code code code code code code code code code quality"
VALIDATORS_COUNT = 2


def run(plan):
    rootchain_rpc_url = rootchain.run(plan, MNEMONIC)

    bor_rpc_url = "http://localhost:8545"
    for i in range(1, VALIDATORS_COUNT + 1):
        heimdall.run(
            plan, i, rootchain_rpc_url, bor_rpc_url, MNEMONIC, VALIDATORS_COUNT
        )
