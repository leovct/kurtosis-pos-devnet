# Kurtosis Polygon PoS Devnet

This is a [Kurtosis](https://github.com/kurtosis-tech/kurtosis) package that will spin up a private Polygon PoS devnet over Docker or Kubernetes. The package is designed to be used for testing, validation and development of Polygon PoS clients. It is not intended for production use.

## Deploy the devnet

```bash
$ kurtosis run --enclave pos-devnet .
INFO[2024-02-19T15:40:35+01:00] Creating a new enclave for Starlark to run inside...
INFO[2024-02-19T15:40:45+01:00] Enclave 'pos-devnet' created successfully
INFO[2024-02-19T15:40:45+01:00] Executing Starlark package at '/Users/leovct/Documents/work/infra/kurtosis/kurtosis-pos-devnet' as the passed argument '.' looks like a directory
INFO[2024-02-19T15:40:45+01:00] Compressing package 'github.com/leovct/kurtosis-pos-devnet' at '.' for upload
INFO[2024-02-19T15:40:45+01:00] Uploading and executing package 'github.com/leovct/kurtosis-pos-devnet'

Container images used in this run:
> trufflesuite/ganache:v7.9.2 - locally cached
> 0xpolygon/heimdall:1.0.3 - locally cached
> rabbitmq:3.12-alpine - locally cached

> add_service name="rootchain" config=ServiceConfig(image="trufflesuite/ganache:v7.9.2", ports={"http_rpc": PortSpec(number=8545, application_protocol="http")}, cmd=["--chain.allowUnlimitedContractSize=false", "--chain.allowUnlimitedInitCodeSize=false", "--chain.asyncRequestProcessing=true", "--chain.chainId=1", "--chain.hardfork=shanghai", "--chain.vmErrorsOnRPCResponse=false", "--database.dbPath=/var/lib/ganache", "--logging.debug=false", "--logging.quiet=false", "--logging.verbose=false", "--miner.blockTime=0", "--miner.defaultGasPrice=0x77359400", "--miner.blockGasLimit=0xb71b00", "--miner.defaultTransactionGasLimit=0x15f90", "--miner.difficulty=0x1", "--miner.callGasLimit=0x2faf080", "--miner.instamine=strict", "--miner.coinbase=0x85dA99c8a7C2C95964c8EfD687E95E632Fc533D6", "--miner.extraData='0x706f6c79676f6e2067616e61636865'", "--miner.priceBump=10", "--wallet.totalAccounts=50", "--wallet.mnemonic='code code code code code code code code code code code quality'", "--wallet.defaultBalance=10000000", "--server.ws=true", "--server.host='0.0.0.0'", "--server.port=8545"])
Service 'rootchain' added with service UUID '1147f40770404251bd60f22bea1c1c45'

> add_service name="rabbitmq" config=ServiceConfig(image="rabbitmq:3.12-alpine", ports={"amqp": PortSpec(number=5672, application_protocol="amqp")})
Service 'rabbitmq' added with service UUID '65b069c438b84757bdf92f725638aeaa'

> add_service name="heimdall" config=ServiceConfig(image="0xpolygon/heimdall:1.0.3", cmd=["start", "--rest-server", "--bridge", "--all", "--amqp_url", "amqp://guest:guest@{{kurtosis:0e8eabc08b6f4ae8b56d47556be4bca1:ip_address.runtime_value}}:5672"])
Service 'heimdall' added with service UUID '166b5adbd9a8435ba532e769ef6f4386'

Starlark code successfully run. No output was returned.

Made with Kurtosis - https://kurtosis.com
INFO[2024-02-19T15:41:01+01:00] ===================================================
INFO[2024-02-19T15:41:01+01:00] ||          Created enclave: pos-devnet          ||
INFO[2024-02-19T15:41:01+01:00] ===================================================
Name:            pos-devnet
UUID:            a9f016595299
Status:          RUNNING
Creation Time:   Mon, 19 Feb 2024 15:40:35 CET
Flags:

========================================= Files Artifacts =========================================
UUID   Name

========================================== User Services ==========================================
UUID           Name        Ports                                          Status
166b5adbd9a8   heimdall    <none>                                         RUNNING
65b069c438b8   rabbitmq    amqp: 5672/tcp -> amqp://127.0.0.1:50397       RUNNING
1147f4077040   rootchain   http_rpc: 8545/tcp -> http://127.0.0.1:50381   RUNNING
```
