# Kurtosis Polygon PoS Devnet

This is a [Kurtosis](https://github.com/kurtosis-tech/kurtosis) package that will spin up a private Polygon PoS devnet over Docker or Kubernetes. The package is designed to be used for testing, validation and development of Polygon PoS clients. It is not intended for production use.

## Deploy the devnet

```bash
$ kurtosis run --enclave pos-devnet --args-file config.yml .
...
Starlark code successfully run. No output was returned.

Made with Kurtosis - https://kurtosis.com
INFO[2024-02-23T11:09:14+01:00] ===================================================
INFO[2024-02-23T11:09:14+01:00] ||          Created enclave: pos-devnet          ||
INFO[2024-02-23T11:09:14+01:00] ===================================================
Name:            pos-devnet
UUID:            b79ef47af6df
Status:          RUNNING
Creation Time:   Fri, 23 Feb 2024 11:08:45 CET
Flags:

========================================= Files Artifacts =========================================
UUID           Name
a0a31d78df85   heimdall-1-config
22cfdf7acf4c   heimdall-2-config

========================================== User Services ==========================================
UUID           Name         Ports                                          Status
b85244b10a92   heimdall-1   <none>                                         RUNNING
6ad18880a651   heimdall-2   <none>                                         RUNNING
d4150ced8806   rabbitmq-1   amqp: 5672/tcp -> amqp://127.0.0.1:64043       RUNNING
866b3e4eee44   rabbitmq-2   amqp: 5672/tcp -> amqp://127.0.0.1:64062       RUNNING
c00398b6daa0   rootchain    http_rpc: 8545/tcp -> http://127.0.0.1:64024   RUNNING
```
