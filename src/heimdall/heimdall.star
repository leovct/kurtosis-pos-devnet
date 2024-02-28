IMAGE = "0xpolygon/heimdall:1.0.3"
CHAIN_ID = "heimdall-137"
DATA_PATH = "/etc/heimdall"


def generate_config_and_scripts(
    plan,
    id,
    heimdall_node_name,
    rootchain_rpc_url,
    bor_rpc_url,
    amqp_url,
    validator_keys_path,
):
    appTemplate = read_file("./config/app.toml")
    baseConfigTemplate = read_file("./config/config.toml")
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
                template=baseConfigTemplate,
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
                    "CHAIN_ID": CHAIN_ID,
                    "DATA_PATH": DATA_PATH,
                    "VAlIDATOR_KEYS_PATH": validator_keys_path,
                    "NODE_ID": id,
                    "AMQP_URL": amqp_url,
                },
            ),
        },
    )


def start(plan, name, config, amqp_url, validator_keys, validator_keys_path):
    service = plan.add_service(
        name=name,
        config=ServiceConfig(
            image=IMAGE,
            files={
                DATA_PATH: config,
                validator_keys_path: validator_keys,
            },
            entrypoint=["/bin/sh", "-c"],
            cmd=[
                "chmod +x {0}/scripts/start.sh && sh {0}/scripts/start.sh".format(
                    DATA_PATH
                )
            ],
        ),
    )
    return service.ip_address
