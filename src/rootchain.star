IMAGE = "trufflesuite/ganache"
TAG = "v7.9.2"

CHAIN_ID = 1
HARDFORK = "shanghai"
DATA_PATH = "/var/lib/ganache"
MINER_COINBASE_ADDRESS = "0x85dA99c8a7C2C95964c8EfD687E95E632Fc533D6"
NUMBER_OF_ACCOUNTS = 50
RPC_PORT = 8545


def run(plan, mnemonic):
    plan.add_service(
        name="rootchain",
        config=ServiceConfig(
            image="{}:{}".format(IMAGE, TAG),
            ports={"http_rpc": PortSpec(RPC_PORT, application_protocol="http")},
            cmd=[
                ## CHAIN
                # Allow unlimited contract size.
                "--chain.allowUnlimitedContractSize=true",
                # Allow unlimited initcode (transaction.data) sizes.
                "--chain.allowUnlimitedInitCodeSize=true",
                # The currently configured chain id.
                "--chain.chainId={}".format(CHAIN_ID),
                # Set the hardfork rules for the EVM.
                "--chain.hardfork={}".format(HARDFORK),
                ## DATABASE
                # Specify a path to a directory to save the chain database.
                "--database.dbPath={}".format(DATA_PATH),
                ## MINER
                # In "strict" mode a transaction's hash is returned to the caller before the
                # transaction is included in a block.
                # Note that blockTime must be set to zero (default value).
                "--miner.instamine=strict",
                # Sets the address where mining rewards will go.
                "--miner.coinbase={}".format(MINER_COINBASE_ADDRESS),
                ## WALLET
                # Number of accounts to generate at startup.
                "--wallet.totalAccounts={}".format(NUMBER_OF_ACCOUNTS),
                # Use a specific HD wallet mnemonic to generate initial addresses.
                "--wallet.mnemonic='{}'".format(mnemonic),
                # The default account balance, specified in ether.
                "--wallet.defaultBalance=10000000",
                ## SERVER
                # The port to listen on.
                "--server.port={}".format(RPC_PORT),
                # Enable a websocket server.
                "--server.ws=false",
            ],
        ),
    )
