BOR_DATA_PATH = "/etc/bor"


def generate_bor_genesis(plan, validator_keys):
    validator_keys_path = "/etc/validators"
    initScriptTemplate = read_file("./scripts/init.sh")
    initScript = plan.render_templates(
        name="bor-genesis-generator-config",
        config={
            "init.sh": struct(
                template=initScriptTemplate,
                data={
                    "BOR_CHAIN_ID": "137",
                    "HEIMDALL_CHAIN_ID": "heimdall-137",
                    "VAlIDATOR_KEYS_PATH": validator_keys_path,
                },
            )
        },
    )

    plan.add_service(
        name="bor-genesis-generator",
        config=ServiceConfig(
            image=ImageBuildSpec(
                image_name="bor-genesis-generator", build_context_dir="."
            ),
            files={
                "/opt/scripts": initScript,
                validator_keys_path: validator_keys,
            },
            entrypoint=["/bin/sh", "-c"],
            cmd=["chmod +x /opt/scripts/init.sh && sh /opt/scripts/init.sh"],
        ),
    )
    response = plan.wait(
        service_name="bor-genesis-generator",
        recipe=ExecRecipe(command=["cat", "/tmp/done"]),
        field="code",
        assertion="==",
        target_value=0,
        timeout="5m",
    )
    return plan.store_service_files(
        service_name="bor-genesis-generator",
        src="/etc/bor/*",
        name="bor-genesis",
    )


def run(
    plan,
    id,
    validator_keys,
    validator_address,
    bor_genesis,
    heimdall_ip_address,
    validator_keys_path,
):
    bor_node_name = "bor-{}".format(id)
    return start_dummy_bor(
        plan,
        bor_node_name,
        bor_genesis,
        validator_keys,
        validator_keys_path,
    )


def generate_bor_config(
    plan,
    id,
    bor_node_name,
    validator_address,
    heimdall_ip_address,
    validator_keys_path,
    static_nodes,
):
    configTemplate = read_file("./config/config.toml")
    passTemplate = read_file("./config/pass.txt")
    return plan.render_templates(
        name="{}-config".format(bor_node_name),
        config={
            "config/config.toml": struct(
                template=configTemplate,
                data={
                    "CHAIN_ID": id,
                    "BOR_NODE_ID": bor_node_name,
                    "BOR_DATA_PATH": BOR_DATA_PATH,
                    "HEIMDALL_NODE_IP_ADDRESS": heimdall_ip_address,
                    "BOR_NODE_ETH_ADDRESS": validator_address,
                    "VALIDATORS_KEY_PATH": validator_keys_path,
                    "STATIC_NODES": static_nodes,
                },
            ),
            "config/pass.txt": struct(template=passTemplate, data={}),
        },
    )


def start_dummy_bor(plan, name, genesis, validator_keys, validator_keys_path):
    service = plan.add_service(
        name,
        config=ServiceConfig(
            image="0xpolygon/bor:1.2.3",
            ports={
                # "http_rpc": PortSpec(8545, application_protocol="http")
            },
            files={
                "{}/genesis".format(BOR_DATA_PATH): genesis,
                validator_keys_path: validator_keys,
            },
            entrypoint=["/bin/sh"]
            # cmd=["server", "--config={}/config/config.toml".format(BOR_DATA_PATH)],
        ),
    )
    return service.ip_address
