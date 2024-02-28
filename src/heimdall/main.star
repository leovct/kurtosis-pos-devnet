rabbitmq = import_module("./rabbitmq.star")
heimdall = import_module("./heimdall.star")


def run(plan, id, validator_keys, rootchain_rpc_url, bor_rpc_url):
    rabbitmq_amqp_url = rabbitmq.start(plan, id)

    validator_keys_path = "/etc/validators"
    heimdall_config = heimdall.generate_config_and_scripts(
        plan,
        id,
        rootchain_rpc_url,
        bor_rpc_url,
        rabbitmq_amqp_url,
        validator_keys_path,
    )
    return heimdall.start(
        plan,
        id,
        heimdall_config,
        validator_keys_path,
        validator_keys,
    )
