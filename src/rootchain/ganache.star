service_utils = import_module("../utils/service.star")
validator_keys_generator = import_module("../validator-keys-generator/main.star")

ROOTCHAIN_IMAGE = "trufflesuite/ganache:v7.9.2"
ROOTCHAIN_SERVICE_NAME = "rootchain"
ROOTCHAIN_CONTRACT_DEPLOYER_SERVICE_NAME = "rootchain-contract-deployer"

CHAIN_ID = 1
DATA_PATH = "/etc/ganache"
HTTP_RPC_PORT = 8545
STAKE_AMOUNT = 10000
FEE_TOPUP = 2000


# Start the rootchain and deploy MATIC contracts.
def run(
    plan, validator_count, rootchain_params, mnemonic, bor_chain_id, validator_keys
):
    rootchain_db = _start_rootchain_contract_deployer(
        plan,
        validator_count,
        rootchain_params,
        mnemonic,
        bor_chain_id,
        validator_keys,
    )
    rootchain_rpc_url = _start_rootchain(plan, validator_count, rootchain_params, mnemonic, rootchain_db)
    return rootchain_rpc_url


# Start the rootchain contract deployer.
def _start_rootchain_contract_deployer(
    plan, validator_count, rootchain_params, mnemonic, bor_chain_id, validator_keys
):
    # Start the rootchain contract deployer.
    ganache_args = _define_ganache_args(validator_count, rootchain_params, mnemonic)
    # Listen on port 9545.
    # Note: The rootchain contract deployer does not listen on port 8545 because the port 9545 is
    # harcoded in `truffle-config.js`, the reference file used when deploying contracts.
    ganache_args.append("--server.port=9545")
    # Allow unlimited contract size.
    ganache_args.append("--chain.allowUnlimitedContractSize=true")

    plan.add_service(
        name=ROOTCHAIN_CONTRACT_DEPLOYER_SERVICE_NAME,
        config=ServiceConfig(
            image=ImageBuildSpec(
                image_name=ROOTCHAIN_CONTRACT_DEPLOYER_SERVICE_NAME,
                build_context_dir=".",
            ),
            ports={
                # Note: The rootchain contract deployer listens on port 9545 and not on port 8545.
                # This is because `truffle-config.js` hardcodes this specific port.
                # This is only required when deploying contracts.
                "http_rpc": PortSpec(9545, application_protocol="http")
            },
            cmd=ganache_args,
        ),
    )

    # Deploy contracts.
    commands = [
        {
            "description": "Processing templates",
            "expression": "cd /opt/matic-contracts && npm run template:process -- --bor-chain-id {}".format(
                bor_chain_id
            ),
        },
        {
            "description": "Compiling contracts",
            "expression": "cd /opt/matic-contracts && npm run truffle:compile",
        },
        {
            "description": "Deploying contracts",
            "expression": "cd /opt/matic-contracts && truffle migrate --network development --to 4 --compile-none",
        },
    ]
    service_utils.exec_commands(
        plan, ROOTCHAIN_CONTRACT_DEPLOYER_SERVICE_NAME, commands
    )

    # Stake for each validator node.
    for id in range(validator_count):
        validator_eth_address = validator_keys[id]["eth_address"]
        validator_public_key = validator_keys[id]["public_key"]
        command = {
            "description": "Staking for node {}".format(id),
            "expression": "npm run truffle exec scripts/stake.js -- --network development {} {} {} {}".format(
                validator_eth_address, validator_public_key, STAKE_AMOUNT, FEE_TOPUP
            ),
        }

    # Store the db state.
    rootchain_db = plan.store_service_files(
        service_name=ROOTCHAIN_CONTRACT_DEPLOYER_SERVICE_NAME,
        src="{}/*".format(DATA_PATH),
        name="rootchain-db",
    )
    # plan.remove_service(ROOTCHAIN_CONTRACT_DEPLOYER_SERVICE_NAME)
    return rootchain_db


# Start the rootchain.
def _start_rootchain(plan, validator_count, rootchain_params, mnemonic, db):
    ganache_args = _define_ganache_args(validator_count, rootchain_params, mnemonic)
    ganache_args.append("--server.port={}".format(HTTP_RPC_PORT))
    service = plan.add_service(
        name=ROOTCHAIN_SERVICE_NAME,
        config=ServiceConfig(
            image=ROOTCHAIN_IMAGE,
            ports={"http_rpc": PortSpec(HTTP_RPC_PORT, application_protocol="http")},
            files={"{}".format(DATA_PATH): db},
            cmd=ganache_args,
        ),
    )
    return "http://{}:{}".format(service.ip_address, HTTP_RPC_PORT)


# Define rootchain parameters.
def _define_ganache_args(validator_count, rootchain_params, mnemonic):
    return [
        # The currently configured chain id.
        "--chain.chainId={}".format(CHAIN_ID),
        # Set the hardfork rules for the EVM.
        "--chain.hardfork={}".format(rootchain_params["hardfork"]),
        # Specify a path to a directory to save the chain database.
        "--database.dbPath={}".format(DATA_PATH),
        # In "strict" mode a transaction's hash is returned to the caller before the
        # transaction is included in a block.
        # Note that blockTime must be set to zero (default value).
        "--miner.instamine=strict",
        # Sets the address where mining rewards will go.
        "--miner.coinbase={}".format(rootchain_params["miner_coinbase_address"]),
        # Number of accounts to generate at startup.
        "--wallet.totalAccounts={}".format(validator_count),
        # Use a specific HD wallet mnemonic to generate initial addresses.
        "--wallet.mnemonic='{}'".format(mnemonic),
        # The default account balance, specified in ether.
        "--wallet.defaultBalance=10000000",
        # The hostname to listen on.
        "--server.host=0.0.0.0",
        # Enable a websocket server.
        "--server.ws=true",
    ]
