def read_file_content(plan, service_name, filename):
    """
    Read the content of a file from a service.

    Args:
        service_name (string): The name of the service.
        filename (string): The name of the file to read from.

    Returns:
        The content of the file as a string.
    """
    result = plan.exec(
        service_name,
        recipe=ExecRecipe(
            command=["/bin/sh", "-c", "cat {} | tr -d '\n'".format(filename)]
        ),
    )
    return result["output"]


def extract_json_key(plan, service_name, filename, key):
    """
    Extract a specific key from a JSON file, located in a service, and return its value.

    Args:
        service_name (string): The name of the service.
        filename (string): The name of the JSON file to read from.
        key (string): The field to extract from the JSON file.
    """
    result = plan.exec(
        service_name,
        recipe=ExecRecipe(
            command=["/bin/sh", "-c", "cat {}".format(filename)],
            extract={"value": "fromjson | .{}".format(key)},
        ),
    )
    return result["extract.value"]
