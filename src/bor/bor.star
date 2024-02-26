BOR_DATA_PATH = "/var/lib/bor"


def generate_bor_genesis(plan, validator_keys):
    validator_keys_path = "/var/lib/validators"
    initScriptTemplate = read_file("./scripts/init.sh")
    initScript = plan.render_templates(
        name="bor-genesis-generator-config",
        config={
            "scripts/init.sh": struct(
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
                BOR_DATA_PATH: initScript,
                validator_keys_path: validator_keys,
            },
            entrypoint=["/bin/sh", "-c"],
            cmd=[
                "chmod +x {0}/scripts/init.sh && sh {0}/scripts/init.sh".format(
                    BOR_DATA_PATH
                )
            ],
        ),
    )
    response = plan.wait(
        service_name="bor-genesis-generator",
        recipe=ExecRecipe(command=["cat", "/opt/genesis-contracts/genesis.json"]),
        field="code",
        assertion="==",
        target_value=0,
        timeout="5m",
    )
    return plan.store_service_files(
        service_name="bor-genesis-generator",
        src="/opt/genesis-contracts/genesis.json",
        name="bor_genesis",
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
            files={
                # BOR_DATA_PATH: config,
                "{}/genesis.json".format(BOR_DATA_PATH): genesis,
                validator_keys_path: validator_keys,
            },
            cmd=["bor", "server"],
        ),
    )
