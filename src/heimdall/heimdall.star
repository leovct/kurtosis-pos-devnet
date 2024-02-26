RABBITMQ_IMAGE = "rabbitmq:3-alpine"
RABBITMQ_PORT = 5672
RABBITMQ_USER = "guest"
RABBITMQ_PASSWORD = "guest"

HEIMDALL_CHAIN_ID = "heimdall-137"
HEIMDALL_DATA_PATH = "/var/lib/heimdall"


def run(plan, id, validator_keys, rootchain_rpc_url, bor_rpc_url):
    rabbitmq_node_name = "rabbitmq-{}".format(id)
    amqp_url = start_rabbitmq(plan, rabbitmq_node_name)

    heimdall_node_name = "heimdall-{}".format(id)
    validator_keys_path = "/var/lib/validators"
    heimdall_config = generate_heimdall_config(
        plan,
        id,
        heimdall_node_name,
        rootchain_rpc_url,
        bor_rpc_url,
        amqp_url,
        validator_keys_path
    )
    start_heimdall(plan, heimdall_node_name, heimdall_config, amqp_url, validator_keys, validator_keys_path)


def start_rabbitmq(plan, name):
    rabbitmq = plan.add_service(
        name,
        config=ServiceConfig(
            image=RABBITMQ_IMAGE,
            ports={"amqp": PortSpec(RABBITMQ_PORT, application_protocol="amqp")},
        ),
    )
    return "amqp://{}:{}@{}:{}".format(
        RABBITMQ_USER, RABBITMQ_PASSWORD, rabbitmq.ip_address, RABBITMQ_PORT
    )


def generate_heimdall_config(
    plan,
    id,
    heimdall_node_name,
    rootchain_rpc_url,
    bor_rpc_url,
    amqp_url,
    validator_keys_path
):
    appTemplate = read_file("./config/app.toml")
    configTemplate = read_file("./config/config.toml")
    heimdallConfigTemplate = read_file("./config/heimdall-config.toml")
    startScript = read_file("./scripts/start.sh")
    return plan.render_templates(
        name="{}-config".format(heimdall_node_name),
        config={
            "config/app.toml": struct(
                template=appTemplate,
                data={},
            ),
            "config/config.toml": struct(
                template=configTemplate,
                data={
                    "HEIMDALL_NODE_NAME": heimdall_node_name,
                },
            ),
            "config/heimdall-config.toml": struct(
                template=heimdallConfigTemplate,
                data={
                    "ROOTCHAIN_RPC_URL": rootchain_rpc_url,
                    "BOR_RPC_URL": bor_rpc_url,
                    "AMQP_URL": amqp_url,
                },
            ),
            "scripts/start.sh": struct(
                template=startScript,
                data={
                    "CHAIN_ID": HEIMDALL_CHAIN_ID,
                    "DATA_PATH": HEIMDALL_DATA_PATH,
                    "VAlIDATOR_KEYS_PATH": validator_keys_path,
                    "NODE_ID": id,
                    "AMQP_URL": amqp_url,
                },
            ),
        },
    )


def start_heimdall(plan, name, config, amqp_url, validator_keys, validator_keys_path):
    plan.add_service(
        name=name,
        config=ServiceConfig(
            image=ImageBuildSpec(
                image_name="heimdall-genesis-generator", build_context_dir="."
            ),
            files={
                HEIMDALL_DATA_PATH: config,
                validator_keys_path: validator_keys,
            },
            entrypoint=["/bin/sh", "-c"],
            cmd=[
                "chmod +x {0}/scripts/start.sh && sh {0}/scripts/start.sh".format(
                    HEIMDALL_DATA_PATH
                )
            ],
        ),
    )
