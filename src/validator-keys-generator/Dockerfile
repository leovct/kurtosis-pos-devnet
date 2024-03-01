FROM golang:1.22 as polycli-builder
WORKDIR /opt/polycli
RUN git clone --branch main https://github.com/maticnetwork/polygon-cli.git . \
    && make build

FROM debian:bookworm-slim
LABEL author="devtools@polygon.technology"
LABEL description="Helper image to generate validator keys"

COPY --from=polycli-builder /opt/polycli/out/polycli /usr/local/bin/polycli
COPY --from=polycli-builder /opt/polycli/bindings/ /opt/bindings/
RUN apt-get --yes update \
    && apt-get install --yes --no-install-recommends jq=1.6-2.1 \
    && rm -rf /var/lib/apt/lists/*
COPY generate-keys.sh /usr/local/bin/
CMD ["sh", "-c", "generate-keys.sh"]
