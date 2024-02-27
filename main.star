bor_module = import_module("./src/bor/main.star")
heimdall_module = import_module("./src/heimdall/main.star")
rootchain_module = import_module("./src/rootchain/main.star")
validator_keys_generator_module = import_module(
    "./src/validator-keys-generator/main.star"
)


def run(plan, validators, mnemonic, rootchain):
    plan.print("validators: {}, mnemonic: {}".format(validators, mnemonic))

    # Generate validator keys.
    validator_keys_path = "/etc/validators"
    validator_keys = validator_keys_generator_module.run(
        plan, validators, mnemonic, validator_keys_path
    )

    # Start the rootchain.
    plan.print("rootchain: {}".format(rootchain))
    rootchain_rpc_url = rootchain_module.run(plan, mnemonic, rootchain)

    # Generate bor genesis.
    bor_genesis = bor_module.generate_bor_genesis(plan, validator_keys)

    # Start a number of heimdall and bor nodes.
    bor_rpc_url = "http://localhost:8545"  # TODO: change me
    for i in range(1, validators + 1):
        result = plan.exec(
            service_name="validator-keys-generator",
            recipe=ExecRecipe(
                command=[
                    "/bin/sh",
                    "-c",
                    "cat {}/validator_{}/address.txt".format(validator_keys_path, i),
                ]
            ),
        )
        validator_address = result["output"]

        heimdall_ip_address = heimdall_module.run(
            plan, i, validator_keys, rootchain_rpc_url, bor_rpc_url
        )

        bor_module.run(
            plan,
            i,
            validator_keys,
            validator_address,
            bor_genesis,
            heimdall_ip_address,
            validator_keys_path,
        )
