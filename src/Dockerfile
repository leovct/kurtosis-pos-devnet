FROM 0xpolygon/heimdall:1.0.3 as heimdall
FROM 0xpolygon/bor:1.2.3 as bor

FROM golang:1.22 as polycli-builder
WORKDIR /app
RUN git clone --branch main https://github.com/maticnetwork/polygon-cli.git \
    && cd polygon-cli \
    && make build

FROM node:16-bookworm
COPY --from=heimdall /usr/bin/heimdall* /usr/local/bin/
COPY --from=bor /usr/bin/bor /usr/local/bin/bor
COPY --from=polycli-builder /app/polygon-cli/out/polycli /usr/local/bin/polycli
COPY --from=polycli-builder /app/polygon-cli/bindings/ /opt/bindings/
RUN apt-get --yes update && apt-get install --yes jq
ENTRYPOINT ["bash"]
