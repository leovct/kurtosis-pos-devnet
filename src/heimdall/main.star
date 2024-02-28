file_utils = import_module("../utils/file.star")
script_utils = import_module("../utils/script.star")
rabbitmq = import_module("./rabbitmq.star")

IMAGE = "0xpolygon/heimdall:1.0.3"
CHAIN_ID = "heimdall-137"
DATA_PATH = "/root/.heimdalld"


def run(plan, id, validator_private_key, rootchain_rpc_url):
    """
    Configure and start a Heimdall node alongside its RabbitMQ service.

    Args:
        id (string): The unique identifier for the node.
        validator_private_key (string): The private key of the validator node.
        rootchain_rpc_url (string): The rootchain RPC URL.

    Returns:
        The IP address of the heimdall node.
    """
    rabbitmq_amqp_url = rabbitmq.start(plan, id)
    config = generate_config(plan, id, rootchain_rpc_url, rabbitmq_amqp_url)
    heimdall_ip_address = start_heimdall_node(plan, id, config, rabbitmq_amqp_url)
    generate_genesis(plan, id, validator_private_key)
    return heimdall_ip_address


def start_heimdall_node(plan, id, config, rabbitmq_amq_url):
    service = plan.add_service(
        name="heimdall-{}".format(id),
        config=ServiceConfig(
            image=IMAGE,
            files={"{}/config".format(DATA_PATH): config},
            entrypoint=["/bin/sh", "-c"],
            cmd=[
                "heimdalld start --all --amqp_url {} --bridge --rest-server".format(
                    rabbitmq_amq_url
                )
            ],
        ),
    )
    return service.ip_address


def generate_config(plan, id, rootchain_rpc_url, rabbitmq_amqp_url):
    """
    Generate configuration files for a Heimdall validator node.

    Args:
        id (string): The unique identifier for the node.
        rootchain_rpc_url (string): The RPC URL of the root chain.
        rabbitmq_amqp_url (string): The AMQP URL of the associated RabbitMQ service.
    """
    app_template = read_file("./config/app.toml")
    base_config_template = read_file("./config/config.toml")
    heimdall_config_template = read_file("./config/heimdall-config.toml")
    return plan.render_templates(
        name="heimdall-{}-config".format(id),
        config={
            "app.toml": struct(
                template=app_template,
                data={},
            ),
            "config.toml": struct(
                template=base_config_template,
                data={
                    "NODE_ID": id,
                },
            ),
            "heimdall-config.toml": struct(
                template=heimdall_config_template,
                data={
                    "ROOTCHAIN_RPC_URL": rootchain_rpc_url,
                    "RABBITMQ_AMQP_URL": rabbitmq_amqp_url,
                },
            ),
        },
    )


def generate_genesis(plan, id, validator_private_key):
    commands = [
        {
            "description": "Generate dummy configuration files (including genesis)",
            "cmd": "heimdalld init --chain-id {} --home {}".format(CHAIN_ID, DATA_PATH),
        },
        {
            "description": "Format the validator private key",
            "cmd": "heimdallcli generate-validatorkey --home {} {}".format(
                DATA_PATH, validator_private_key
            ),
        },
        {
            "description": "Generate the final genesis file",
            "cmd": "heimdalld init --chain-id {0} --home {1} --id {2} --overwrite-genesis 2> {1}/node_id.json".format(
                CHAIN_ID, DATA_PATH, id
            ),
        },
    ]
    for command in commands:
        plan.print(command["description"])
        exec_recipe = ExecRecipe(command=["/bin/sh", "-c", command["cmd"]])
        plan.exec(service_name="heimdall-{}".format(id), recipe=exec_recipe)


def replace_bor_rpc_url_in_config(plan, id, bor_node_ip_address):
    """
    Replace the dummy Bor rpc URL in Heimdall config.

    Args:
        id (string): The unique identifier for the node.
        bor_node_ip_address (string): The ip address of the associated Bor node.
    """
    expression = 's/bor_rpc_url = "http:\\/\\/bor_rpc_url:8545"/bor_rpc_url = "http:\\/\\/{}:8545"/'.format(
        bor_node_ip_address
    )
    file_utils.sed(
        plan,
        "heimdall-{}".format(id),
        expression,
        "{}/config/heimdall-config.toml".format(DATA_PATH),
    )


def replace_static_peers_in_config(plan, id, static_peers):
    expression = 's/persistent_peers = ""/persistent_peers = "{}"/'.format(
        static_peers
    ).replace("http://", "http:\\/\\/")
    file_utils.sed(
        plan,
        "heimdall-{}".format(id),
        expression,
        "{}/config/config.toml".format(DATA_PATH),
    )
