IMAGE = "rabbitmq:3-alpine"
PORT = 5672
USER = "guest"
PASSWORD = "guest"


def start(plan, id):
    """
    Start a RabbitMQ service in the execution plan.

    Args:
        id (string): The unique identifier for the service.

    Returns:
        The AMQP connection string for the RabbitMQ service.
    """
    rabbitmq = plan.add_service(
        name="rabbitmq-{}".format(id),
        config=ServiceConfig(
            image=IMAGE,
            ports={"amqp": PortSpec(PORT, application_protocol="amqp")},
        ),
    )
    return "amqp://{}:{}@{}:{}".format(USER, PASSWORD, rabbitmq.ip_address, PORT)
