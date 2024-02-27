BOR_DATA_PATH = "/var/lib/bor"


def generate_bor_genesis(plan, validator_keys):
    validator_keys_path = "/var/lib/validators"
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
        src="/var/lib/bor/*",
        name="bor-genesis",
    )


def run(plan, id, validator_keys, bor_genesis):
    bor_node_name = "bor-{}".format(id)
    validator_keys_path = "/var/lib/validators"
    start_bor(
        plan,
        bor_node_name,
        bor_genesis,
        validator_keys,
        validator_keys_path,
    )


def start_bor(plan, name, genesis, validator_keys, validator_keys_path):
    return plan.add_service(
        name,
        config=ServiceConfig(
            image="0xpolygon/bor:1.2.3",
            ports={
                # "http_rpc": PortSpec(8545, application_protocol="http")
            },
            files={
                # BOR_DATA_PATH: config,
                "/opt/bor": genesis,
                validator_keys_path: validator_keys,
            },
            cmd=["server"],
        ),
    )
