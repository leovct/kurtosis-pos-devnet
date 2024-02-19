RABBITMQ_IMAGE = "rabbitmq"
RABBITMQ_TAG = "3.12-alpine"
RABBITMQ_PORT = 5672
RABBITMQ_USER = "guest"
RABBITMQ_PASSWORD = "guest"

HEIMDALL_IMAGE = "0xpolygon/heimdall"
HEIMDALL_TAG = "1.0.3"
TENDERMINT_RPC_PORT = 1317
TENDERMINT_P2P_PORT = 26656
ETHEREUM_P2P_PORT = 30303


def run(plan):
    rabbitmq = plan.add_service(
        name="rabbitmq",
        config=ServiceConfig(
            image="{0}:{1}".format(RABBITMQ_IMAGE, RABBITMQ_TAG),
            ports={"amqp": PortSpec(RABBITMQ_PORT, application_protocol="amqp")},
        ),
    )
    rabbitmq_ip_address = rabbitmq.ip_address

    heimdall = plan.add_service(
        name="heimdall",
        config=ServiceConfig(
            image="{0}:{1}".format(HEIMDALL_IMAGE, HEIMDALL_TAG),
            ports = {
            #    "tendermint_rpc": PortSpec(TENDERMINT_RPC_PORT, application_protocol= "http")
            #    "tendermint_p2p": PortSpec(TENDERMINT_P2P_PORT, application_protocol="http"),
              "ethereum_p2p": PortSpec(ETHEREUM_P2P_PORT, application_protocol="http")
            },
            cmd=[
                "start",
                "--rest-server",
                "--bridge",
                "--all",
                "--amqp_url",
                "amqp://{0}:{1}@{2}:{3}".format(
                    RABBITMQ_USER, RABBITMQ_PASSWORD, rabbitmq_ip_address, RABBITMQ_PORT
                ),
            ],
        ),
    )
    # heimdall_ip_address = heimdall.ip_address
    # heimdall_tendermint_rpc_port = heimdall.ports["tendermint_rpc"].number
    # heimdall_tendermint_p2p_port = heimdall.ports["tendermint_p2p"].number
    # heimdall_ethereum_p2p_port = heimdall.ports["ethereum_p2p"].number
