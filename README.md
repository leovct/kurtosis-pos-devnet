# Kurtosis Polygon PoS Devnet

This is a [Kurtosis](https://github.com/kurtosis-tech/kurtosis) package that will spin up a private Polygon PoS devnet over Docker or Kubernetes. The package is designed to be used for testing, validation and development of Polygon PoS clients. It is not intended for production use.

## Deploy the devnet

```bash
$ kurtosis run --enclave pos-devnet main.star
INFO[2024-02-16T12:09:16+01:00] Creating a new enclave for Starlark to run inside...
INFO[2024-02-16T12:09:18+01:00] Enclave 'pos-devnet' created successfully

> print msg="hello world!"
hello world!

Starlark code successfully run. No output was returned.

Made with Kurtosis - https://kurtosis.com
INFO[2024-02-16T12:09:20+01:00] ===================================================
INFO[2024-02-16T12:09:20+01:00] ||          Created enclave: pos-devnet          ||
INFO[2024-02-16T12:09:20+01:00] ===================================================
Name:            pos-devnet
UUID:            ffef8fab43f3
Status:          RUNNING
Creation Time:   Fri, 16 Feb 2024 12:09:16 CET
Flags:

========================================= Files Artifacts =========================================
UUID   Name

========================================== User Services ==========================================
UUID   Name   Ports   Status
```
