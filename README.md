# Kurtosis Polygon PoS Devnet

This is a [Kurtosis](https://github.com/kurtosis-tech/kurtosis) package that will spin up a private Polygon PoS devnet over Docker or Kubernetes. The package is designed to be used for testing, validation and development of Polygon PoS clients. It is not intended for production use.

## Deploy the devnet

```bash
$ kurtosis clean -a && kurtosis run --enclave pos-devnet --args-file config.yml .
...
Starlark code successfully run. No output was returned.

Made with Kurtosis - https://kurtosis.com
INFO[2024-02-27T15:49:36+01:00] ===================================================
INFO[2024-02-27T15:49:36+01:00] ||          Created enclave: pos-devnet          ||
INFO[2024-02-27T15:49:36+01:00] ===================================================
Name:            pos-devnet
UUID:            a60f2322953c
Status:          RUNNING
Creation Time:   Tue, 27 Feb 2024 15:48:50 CET
Flags:

========================================= Files Artifacts =========================================
UUID           Name
4506a485c34e   bor-1-config
875aac9b3e3c   bor-2-config
261c65c48f5b   bor-genesis
6e23d794ff3b   bor-genesis-generator-config
f4888ed09824   heimdall-1-config
72fabe931a59   heimdall-2-config
7c8e67e59b0d   validator-keys

========================================== User Services ==========================================
UUID           Name                       Ports                                          Status
b6ddca53d379   bor-1                      <none>                                         RUNNING
66d7c66e770a   bor-2                      <none>                                         RUNNING
aab568d9da9a   bor-genesis-generator      <none>                                         STOPPED
7fae8d0530c9   heimdall-1                 <none>                                         RUNNING
d0191281061e   heimdall-2                 <none>                                         RUNNING
458d6bfe142d   rabbitmq-1                 amqp: 5672/tcp -> amqp://127.0.0.1:56564       RUNNING
7dbe1c238019   rabbitmq-2                 amqp: 5672/tcp -> amqp://127.0.0.1:56573       RUNNING
c85ec08f96e8   rootchain                  http_rpc: 8545/tcp -> http://127.0.0.1:56526   RUNNING
ff39f0c136cb   validator-keys-generator   <none>                                         RUNNING
```
