rabbitmq = import_module("./rabbitmq.star")
heimdall = import_module("./heimdall.star")


def run(plan, id, validator_keys, rootchain_rpc_url, bor_rpc_url):
    rabbitmq_service_name = "rabbitmq-{}".format(id)
    rabbitmq_amqp_url = rabbitmq.start(plan, rabbitmq_service_name)

    heimdall_node_name = "heimdall-{}".format(id)
    validator_keys_path = "/etc/validators"
    heimdall_config = heimdall.generate_config_and_scripts(
        plan,
        id,
        heimdall_node_name,
        rootchain_rpc_url,
        bor_rpc_url,
        rabbitmq_amqp_url,
        validator_keys_path,
    )
    return heimdall.start(
        plan,
        heimdall_node_name,
        heimdall_config,
        rabbitmq_amqp_url,
        validator_keys,
        validator_keys_path,
    )
