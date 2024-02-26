BOR_DATA_PATH = "/var/lib/bor"


def run(plan, id):
    bor_node_name = "bor-{}".format(id)
    bor_config = generate_bor_config(plan, id, bor_node_name)
    start_bor(plan, bor_node_name, bor_config)


def generate_bor_config(plan, id, bor_node_name):
    initScript = read_file("./scripts/init.sh")
    return plan.render_templates(
        name="{}-config".format(bor_node_name),
        config={
            "scripts/init.sh": struct(
                template=initScript,
                data={
                    "BOR_CHAIN_ID": "137",
                    "HEIMDALL_CHAIN_ID": "heimdall-137",
                    "VALIDATORS": "2",
                    "MNEMONIC": "code code code code code code code code code code code quality",
                },
            )
        },
    )


def start_bor(plan, name, config):
    bor = plan.add_service(
        name,
        config=ServiceConfig(
            image=ImageBuildSpec(
                image_name="bor-genesis-generator", build_context_dir="."
            ),
            files={
                "{}".format(BOR_DATA_PATH): config,
            },
            entrypoint=["/bin/sh", "-c"],
            cmd=[
                "chmod +x {0}/scripts/init.sh && sh {0}/scripts/init.sh".format(
                    BOR_DATA_PATH
                )
            ],
        ),
    )
