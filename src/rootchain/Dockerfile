FROM node:16-bookworm as contract-deployer
LABEL description="Docker image to deploy a Ganache root chain with MATIC contracts deployed"
LABEL author="devtools@polygon.technology"

RUN npm install ganache@v7.9.2 truffle@5.11.5 --global \
  && apt-get --yes update \
  && apt-get install --yes --no-install-recommends jq=1.6-2.1 \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/matic-contracts
RUN git clone --branch mardizzone/node-16 https://github.com/maticnetwork/contracts.git /opt/matic-contracts \
  && npm install
  # TODO: Once build-args are supported by Kurtosis ImageBuildSpec, add this.
  #&& npm run template:process -- --bor-chain-id "$BOR_CHAIN_ID" \
  #&& npm run truffle:compile \
  # Note: Make sure that MNEMONIC is set.
  #&& truffle migrate --network development --to 4 --compile-none
ENTRYPOINT ["ganache"]
