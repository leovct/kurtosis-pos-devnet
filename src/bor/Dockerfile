FROM node:16-bookworm
LABEL author="devtools@polygon.technology"
LABEL description="Helper image to generate Bor genesis file"

RUN wget --progress=dot:giga --output-document=/usr/local/bin/solc https://github.com/ethereum/solidity/releases/download/v0.5.17/solc-static-linux \
  && chmod +x /usr/local/bin/solc

# We try to compile as much as contracts as possible before adding any templates.
WORKDIR /opt/genesis-contracts
# Note: We ignore the warning to use WORKDIR to switch a directory in order to pack all the RUN
# instructions into one single RUN. This makes the image smaller.
# hadolint ignore=DL3003
RUN git clone --branch master https://github.com/maticnetwork/genesis-contracts.git . \
  && npm install \
  # Do not build test contracts.
  && npm run truffle:compile -- *.sol \
  && git submodule init \
  && git submodule update \
  && cd matic-contracts \
  && npm install

ENTRYPOINT ["bash"]
