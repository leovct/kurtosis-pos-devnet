FROM 0xpolygon/heimdall:1.0.3 as heimdall

FROM golang:1.22 as polycli-builder
WORKDIR /opt/polycli
RUN git clone --branch main https://github.com/maticnetwork/polygon-cli.git . \
    && make build

FROM node:16-bookworm
LABEL author="devtools@polygon.technology"
LABEL description="Helper image to generate Heimdall genesis file"

COPY --from=heimdall /usr/bin/heimdall* /usr/local/bin/
COPY --from=polycli-builder /opt/polycli/out/polycli /usr/local/bin/polycli
COPY --from=polycli-builder /opt/polycli/bindings/ /opt/bindings/
RUN apt-get --yes update \
    && apt-get install --yes --no-install-recommends jq=1.6-2.1 \
    && rm -rf /var/lib/apt/lists/*
ENTRYPOINT ["bash"]
