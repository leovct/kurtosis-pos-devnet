service_utils = import_module("../utils/service.star")
script_utils = import_module("../utils/script.star")

IMAGE = "0xpolygon/bor:1.2.3"
BOR_CHAIN_ID = "137"
HEIMDALL_CHAIN_ID = "heimdall-137"  # TODO: Remove harcoded value.
DATA_PATH = "/etc/bors"


# Configure and start a Bor node.
def run(plan, id, validator_address, heimdall_node_ip_address, bor_genesis):
    bor_config = _generate_config(plan, id, validator_address, heimdall_node_ip_address)
    bor_ip_address = _start_node(plan, id, bor_config, bor_genesis)


# Start the Bor node.
def _start_node(plan, id, config, genesis):
    service = plan.add_service(
        name="bor-{}".format(id + 1),
        config=ServiceConfig(
            image=IMAGE,
            ports={
                # TODO: Find how to expose those ports.
                # "http_rpc": PortSpec(8545, application_protocol="http")
            },
            files={
                "{}/config".format(DATA_PATH): config,
                "{}/genesis".format(DATA_PATH): genesis,
            },
            cmd=["server", "--config={}/config/config.toml".format(DATA_PATH)],
        ),
    )
    return service.ip_address


# Generate configuration files.
def _generate_config(plan, id, validator_address, heimdall_node_ip_address):
    config_template = read_file("./config/config.toml")
    pass_template = read_file("./config/pass.txt")
    return plan.render_templates(
        name="bor-{}-config".format(id + 1),
        config={
            "config.toml": struct(
                template=config_template,
                data={
                    "NODE_ID": id,
                    "DATA_PATH": DATA_PATH,
                    "HEIMDALL_NODE_IP_ADDRESS": heimdall_node_ip_address,
                    "VALIDATOR_ADDRESS": validator_address,
                },
            ),
            "pass.txt": struct(template=pass_template, data={}),
        },
    )


# Generate genesis file.
def generate_bor_genesis(plan, keys_artifact):
    genesis_generator_service_name = "bor-genesis-generator"
    genesis_folder = "/etc/bor/genesis"

    genesis_script_template = read_file("./generate-genesis.sh")
    genesis_script = plan.render_templates(
        name="{}-config".format(genesis_generator_service_name),
        config={
            "generate-genesis.sh": struct(
                template=genesis_script_template,
                data={
                    "BOR_CHAIN_ID": BOR_CHAIN_ID,
                    "HEIMDALL_CHAIN_ID": HEIMDALL_CHAIN_ID,  # TODO: Remove harcoded value.
                    "GENESIS_FOLDER": genesis_folder,
                    "VAlIDATOR_KEYS_PATH": "/var/lib/keys", # TODO: remove hardcoded value
                },
            )
        },
    )

    execute_script_cmd = script_utils.define_execute_script_command(
        "/opt/scripts/generate-genesis.sh"
    )
    ready_condition = service_utils.define_completion_file_ready_condition()
    plan.add_service(
        name=genesis_generator_service_name,
        config=ServiceConfig(
            image=ImageBuildSpec(
                image_name=genesis_generator_service_name, build_context_dir="."
            ),
            files={
                "/opt/scripts": genesis_script,
                "/var/lib/keys": keys_artifact, # TODO: Fix genesis issue.
            },
            entrypoint=["/bin/sh", "-c"],
            cmd=[execute_script_cmd],
            ready_conditions=ready_condition,
        ),
    )
    return plan.store_service_files(
        service_name=genesis_generator_service_name,
        src="{}/*".format(genesis_folder),
        name="bor-genesis",
    )


# Update addresses in configuration files and restart the Bor node.
# Note: Instead of harcoding addresses, they are randomly generated once services are started.
# Thus, we retrieve those addresses and update the configuration files accordingly.
def update_config_and_restart(plan, id, bor_static_peers):
    _replace_static_nodes_in_config(plan, id, bor_static_peers)
    service_utils.restart_service(plan, "bor-{}".format(id + 1))


# Replace the `static-nodes` placeholder in configuration.
def _replace_static_nodes_in_config(plan, id, static_nodes):
    expression = "s/static-nodes = \\[\\]/static-nodes = {}]/".format(static_nodes)
    service_utils.sed_file_in_service(
        plan,
        "bor-{}".format(id + 1),
        expression,
        "{}/config/config.toml".format(DATA_PATH),
    )
