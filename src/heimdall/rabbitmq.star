IMAGE = "rabbitmq:3-alpine"
PORT = 5672
USER = "guest"
PASSWORD = "guest"


# Start a RabbitMQ service.
def start(plan, id):
    rabbitmq = plan.add_service(
        name="rabbitmq-{}".format(id),
        config=ServiceConfig(
            image=IMAGE,
            ports={"amqp": PortSpec(PORT, application_protocol="amqp")},
        ),
    )
    return "amqp://{}:{}@{}:{}".format(USER, PASSWORD, rabbitmq.ip_address, PORT)
