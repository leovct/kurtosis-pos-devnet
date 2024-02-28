rabbitmq = import_module("./rabbitmq.star")
heimdall = import_module("./heimdall.star")


def run(plan, id, validator_private_key, rootchain_rpc_url, bor_rpc_url):
    """
    Configure and start a Heimdall node alongside its RabbitMQ service.

    Args:
        id (string): The unique identifier for the node.
        validator_private_key (string): The private key of the validator node.
        rootchain_rpc_url (string): The rootchain RPC URL.
        bor_rpc_url (string): The associated Bor node RPC URL.

    Returns:
        The ip address of the heimdall service.
    """
    rabbitmq_amqp_url = rabbitmq.start(plan, id)
    config = heimdall.generate_config_and_scripts(
        plan,
        id,
        validator_private_key,
        rootchain_rpc_url,
        bor_rpc_url,
        rabbitmq_amqp_url,
    )
    heimdall_ip_address = heimdall.start(plan, id, config)
    return heimdall_ip_address
