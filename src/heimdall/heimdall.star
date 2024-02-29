service_utils = import_module("../utils/service.star")

IMAGE = "0xpolygon/heimdall:1.0.3"
CHAIN_ID = "heimdall-137"
DATA_PATH = "/root/.heimdalld"


# Start the Heimdall node.
def start_node(plan, id, config, rabbitmq_amq_url):
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


# Generate configuration files.
def generate_config(plan, id, rootchain_rpc_url, rabbitmq_amqp_url):
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


# Generate genesis file.
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


# Replace the `bor_rpc_url` placeholder in configuration.
def replace_bor_rpc_url_in_config(plan, id, bor_node_ip_address):
    expression = 's/bor_rpc_url = "http:\\/\\/bor_rpc_url:8545"/bor_rpc_url = "http:\\/\\/{}:8545"/'.format(
        bor_node_ip_address
    )
    service_utils.sed_file_in_service(
        plan,
        "heimdall-{}".format(id),
        expression,
        "{}/config/heimdall-config.toml".format(DATA_PATH),
    )


# Replace the `persistent_peers` placeholder in configuration.
def replace_static_peers_in_config(plan, id, heimdall_static_peers):
    expression = 's/persistent_peers = ""/persistent_peers = "{}"/'.format(
        heimdall_static_peers
    ).replace("http://", "http:\\/\\/")
    service_utils.sed_file_in_service(
        plan,
        "heimdall-{}".format(id),
        expression,
        "{}/config/config.toml".format(DATA_PATH),
    )
