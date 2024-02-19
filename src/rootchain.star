ROOTCHAIN_IMAGE = "trufflesuite/ganache"
ROOTCHAIN_TAG = "v7.9.2"
ROOTCHAIN_HTTP_RPC_PORT = 8545

MNEMONIC = "code code code code code code code code code code code quality"


def run(plan):
    # TODO: add more parameters
    rootchain = plan.add_service(
        name="rootchain",
        config=ServiceConfig(
            image="{0}:{1}".format(ROOTCHAIN_IMAGE, ROOTCHAIN_TAG),
            ports={
                "http_rpc": PortSpec(
                    ROOTCHAIN_HTTP_RPC_PORT, application_protocol="http"
                )
            },
            cmd=[
                "--chain.allowUnlimitedContractSize=false",
                "--chain.allowUnlimitedInitCodeSize=false",
                "--chain.asyncRequestProcessing=true",
                "--chain.chainId=1",
                "--chain.hardfork=shanghai",
                "--chain.vmErrorsOnRPCResponse=false",
                "--database.dbPath=/var/lib/ganache",
                "--logging.debug=false",
                "--logging.quiet=false",
                "--logging.verbose=false",
                "--miner.blockTime=0",
                "--miner.defaultGasPrice=0x77359400",
                "--miner.blockGasLimit=0xb71b00",
                "--miner.defaultTransactionGasLimit=0x15f90",
                "--miner.difficulty=0x1",
                "--miner.callGasLimit=0x2faf080",
                "--miner.instamine=strict",
                "--miner.coinbase=0x85dA99c8a7C2C95964c8EfD687E95E632Fc533D6",
                "--miner.extraData='0x706f6c79676f6e2067616e61636865'",
                "--miner.priceBump=10",
                "--wallet.totalAccounts=50",
                "--wallet.mnemonic='{0}'".format(MNEMONIC),
                "--wallet.defaultBalance=10000000",
                "--server.ws=true",
                "--server.host='0.0.0.0'",
                "--server.port={0}".format(ROOTCHAIN_HTTP_RPC_PORT),
            ],
        ),
    )
