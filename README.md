# Kurtosis Polygon PoS Devnet

This is a [Kurtosis](https://github.com/kurtosis-tech/kurtosis) package that will spin up a private Polygon PoS devnet over Docker or Kubernetes. The package is designed to be used for testing, validation and development of Polygon PoS clients. It is not intended for production use.

## Deploy the devnet

```bash
$ kurtosis run --enclave pos-devnet github.com/leovct/kurtosis-pos-devnet
# equivalent: kurtosis run --enclave pos-devnet .
# equivalent: kurtosis run --enclave pos-devnet --args-file ./config/config_with_custom_rootchain.yml .
...
Starlark code successfully run. No output was returned.

Made with Kurtosis - https://kurtosis.com
INFO[2024-02-29T19:44:42+01:00] ===================================================
INFO[2024-02-29T19:44:42+01:00] ||          Created enclave: pos-devnet          ||
INFO[2024-02-29T19:44:42+01:00] ===================================================
Name:            pos-devnet
UUID:            89266da1faaa
Status:          RUNNING
Creation Time:   Thu, 29 Feb 2024 19:41:33 CET
Flags:

========================================= Files Artifacts =========================================
UUID           Name
276ea945bdd3   bor-0-config
3f41278b3ad0   bor-1-config
2dac344c4aca   bor-2-config
1ff172dd36bc   bor-3-config
04dde35e14d5   bor-genesis
9e2e5a6088b9   bor-genesis-generator-config
a9a8d2bd2411   heimdall-0-config
6574e2e25d18   heimdall-1-config
458228b35765   heimdall-2-config
1bebaa4bc453   heimdall-3-config
3bae05d2f121   rootchain-db
803c4431e52e   validator-keys

========================================== User Services ==========================================
UUID           Name                          Ports                                                Status
495e0b1cbaa7   bor-0                         http_rpc: 8545/tcp -> http://127.0.0.1:58424         RUNNING
58e95fe1929e   bor-1                         http_rpc: 8545/tcp -> http://127.0.0.1:58427         RUNNING
f63e3a77fdd1   bor-2                         http_rpc: 8545/tcp -> http://127.0.0.1:58430         RUNNING
cdc0dc84616f   bor-3                         http_rpc: 8545/tcp -> http://127.0.0.1:58433         RUNNING
60030471b1e7   heimdall-0                    tendermint_p2p: 26656/tcp -> tcp://127.0.0.1:58423   RUNNING
                                             tendermint_rpc: 1317/tcp -> http://127.0.0.1:58422
a030764f9e4c   heimdall-1                    tendermint_p2p: 26656/tcp -> tcp://127.0.0.1:58426   RUNNING
                                             tendermint_rpc: 1317/tcp -> http://127.0.0.1:58425
a939df5ca331   heimdall-2                    tendermint_p2p: 26656/tcp -> tcp://127.0.0.1:58429   RUNNING
                                             tendermint_rpc: 1317/tcp -> http://127.0.0.1:58428
035a03fb23ba   heimdall-3                    tendermint_p2p: 26656/tcp -> tcp://127.0.0.1:58431   RUNNING
                                             tendermint_rpc: 1317/tcp -> http://127.0.0.1:58432
11d9ec7f15b5   rabbitmq-0                    amqp: 5672/tcp -> amqp://127.0.0.1:58352             RUNNING
7b4f7cc8ef1c   rabbitmq-1                    amqp: 5672/tcp -> amqp://127.0.0.1:58374             RUNNING
19687d2f6c60   rabbitmq-2                    amqp: 5672/tcp -> amqp://127.0.0.1:58381             RUNNING
7c975c4c5798   rabbitmq-3                    amqp: 5672/tcp -> amqp://127.0.0.1:58400             RUNNING
89f8b6addaeb   rootchain                     http_rpc: 8545/tcp -> http://127.0.0.1:58315         RUNNING
```
