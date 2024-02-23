def run(plan, mnemonic, rootchain):
    service = plan.add_service(
        name="rootchain",
        config=ServiceConfig(
            image=rootchain["image"],
            ports={
                "http_rpc": PortSpec(rootchain["rpc_port"], application_protocol="http")
            },
            cmd=[
                ## CHAIN
                # Allow unlimited contract size.
                "--chain.allowUnlimitedContractSize=true",
                # Allow unlimited initcode (transaction.data) sizes.
                "--chain.allowUnlimitedInitCodeSize=true",
                # The currently configured chain id.
                "--chain.chainId={}".format(rootchain["chain_id"]),
                # Set the hardfork rules for the EVM.
                "--chain.hardfork={}".format(rootchain["hardfork"]),
                ## DATABASE
                # Specify a path to a directory to save the chain database.
                "--database.dbPath={}".format(rootchain["data_path"]),
                ## MINER
                # In "strict" mode a transaction's hash is returned to the caller before the
                # transaction is included in a block.
                # Note that blockTime must be set to zero (default value).
                "--miner.instamine=strict",
                # Sets the address where mining rewards will go.
                "--miner.coinbase={}".format(rootchain["miner_coinbase_address"]),
                ## WALLET
                # Number of accounts to generate at startup.
                "--wallet.totalAccounts={}".format(rootchain["accounts"]),
                # Use a specific HD wallet mnemonic to generate initial addresses.
                "--wallet.mnemonic='{}'".format(mnemonic),
                # The default account balance, specified in ether.
                "--wallet.defaultBalance=10000000",
                ## SERVER
                # The port to listen on.
                "--server.port={}".format(rootchain["rpc_port"]),
                # Enable a websocket server.
                "--server.ws=false",
            ],
        ),
    )
    return "http://{}:{}".format(service.ip_address, rootchain["rpc_port"])
