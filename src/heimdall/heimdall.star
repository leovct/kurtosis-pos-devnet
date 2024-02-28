script_utils = import_module("../utils/script.star")

IMAGE = "0xpolygon/heimdall:1.0.3"
CHAIN_ID = "heimdall-137"
DATA_PATH = "/etc/heimdall"


def generate_config_and_scripts(
    plan,
    id,
    rootchain_rpc_url,
    bor_rpc_url,
    rabbitmq_amqp_url,
    validator_keys_path,
):
    """
    Generate configuration files and scripts for a Heimdall node.

    Args:
        id (string): The unique identifier for the node.
        rootchain_rpc_url (string): The RPC URL of the root chain.
        bor_rpc_url (string): The RPC URL of the associated Bor node.
        rabbitmq_amqp_url (string): The AMQP URL of the associated RabbitMQ service.
        validator_keys_path (string): The path to validator keys.
    """
    app_template = read_file("./config/app.toml")
    base_config_template = read_file("./config/config.toml")
    heimdall_config_template = read_file("./config/heimdall-config.toml")
    start_script = read_file("./scripts/start.sh")
    return plan.render_templates(
        name="heimdall-{}-config".format(id),
        config={
            "config/app.toml": struct(
                template=app_template,
                data={},
            ),
            "config/config.toml": struct(
                template=base_config_template,
                data={
                    "NODE_ID": id,
                },
            ),
            "config/heimdall-config.toml": struct(
                template=heimdall_config_template,
                data={
                    "ROOTCHAIN_RPC_URL": rootchain_rpc_url,
                    "BOR_RPC_URL": bor_rpc_url,
                    "RABBITMQ_AMQP_URL": rabbitmq_amqp_url,
                },
            ),
            "scripts/start.sh": struct(
                template=start_script,
                data={
                    "CHAIN_ID": CHAIN_ID,
                    "DATA_PATH": DATA_PATH,
                    "VAlIDATOR_KEYS_PATH": validator_keys_path,
                    "NODE_ID": id,
                    "AMQP_URL": rabbitmq_amqp_url,
                },
            ),
        },
    )


def start(plan, id, config, validator_keys_path, validator_keys):
    """
    Start a Heimdall node.

    Args:
        id (string): The unique identifier for the Heimdall node.
        config_path (str): The path to Heimdall configuration files.
        validator_keys_path (str): The path to validator keys.

    Returns:
        str: The IP address of the started Heimdall node service.
    """
    cmd = script_utils.define_execute_script_command(
        "{}/scripts/start.sh".format(DATA_PATH)
    )
    service = plan.add_service(
        name="heimdall-{}".format(id),
        config=ServiceConfig(
            image=IMAGE,
            files={
                DATA_PATH: config,
                validator_keys_path: validator_keys,
            },
            entrypoint=["/bin/sh", "-c"],
            cmd=cmd,
        ),
    )
    return service.ip_address
