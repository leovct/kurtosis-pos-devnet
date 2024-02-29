rabbitmq = import_module("./rabbitmq.star")
heimdall = import_module("./heimdall.star")
service_utils = import_module("../utils/service.star")


# Configure and start a Heimdall node alongside its RabbitMQ service.
def run(plan, id, validator_private_key, rootchain_rpc_url):
    rabbitmq_amqp_url = rabbitmq.start(plan, id)
    heimdall_config = heimdall.generate_config(
        plan, id, rootchain_rpc_url, rabbitmq_amqp_url
    )
    heimdall_ip_address = heimdall.start_node(
        plan, id, heimdall_config, rabbitmq_amqp_url
    )
    heimdall.generate_genesis(plan, id, validator_private_key)
    return heimdall_ip_address


# Update addresses in configuration files and restart the Heimdall node.
# Note: Instead of harcoding addresses, they are randomly generated once services are started.
# Thus, we retrieve those addresses and update the configuration files accordingly.
def update_config(plan, id, bor_node_ip_address, heimdall_static_peers):
    heimdall.replace_bor_rpc_url_in_config(plan, id, bor_node_ip_address)
    heimdall.replace_static_peers_in_config(plan, id, heimdall_static_peers)
    service_utils.restart_service(plan, "heimdall-{}".format(id))
