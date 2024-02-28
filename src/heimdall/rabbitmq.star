IMAGE = "rabbitmq:3-alpine"
PORT = 5672
USER = "guest"
PASSWORD = "guest"


def start(plan, name):
    """
    Start a RabbitMQ service in the execution plan.

    Args:
        name (str): The name to assign to the RabbitMQ service.

    Returns:
        The AMQP connection string for the RabbitMQ service.
    """
    rabbitmq = plan.add_service(
        name=name,
        config=ServiceConfig(
            image=IMAGE,
            ports={"amqp": PortSpec(PORT, application_protocol="amqp")},
        ),
    )
    return "amqp://{}:{}@{}:{}".format(USER, PASSWORD, rabbitmq.ip_address, PORT)
