def read_file(plan, service_name, filename):
    """
    Read a file from a service and return its content.

    Args:
        service_name (string): The name of the service.
        filename (string): The name of the file to read from.

    Returns:
        The content of the file
    """
    result = plan.exec(
        service_name=service_name,
        recipe=ExecRecipe(
            command=["/bin/sh", "-c", "cat {} | tr -d '\n'".format(filename)]
        ),
    )
    return result["output"]


def extract_field_from_json_file(plan, service_name, filename, field):
    """
    Extract a specific field from a json file located in a service and return its value.

    Args:
        service_name (string): The name of the service.
        filename (string): The name of the json file to read from.
        field (string): The field to extract from the json file.
    """
    result = plan.exec(
        service_name=service_name,
        recipe=ExecRecipe(
            command=[
                "/bin/sh",
                "-c",
                "jq -r '.{}' {} | tr -d '\n'".format(field, filename),
            ]
        ),
    )
    return result["output"]
