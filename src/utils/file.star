def read_file_content(plan, service_name, filename):
    """
    Read the content of a file from a service.

    Args:
        service_name (string): The name of the service.
        filename (string): The name of the file to read from.

    Returns:
        The content of the file, as a string.
    """
    exec_recipe = ExecRecipe(
        command=["/bin/sh", "-c", "cat {} | tr -d '\n'".format(filename)]
    )
    result = plan.exec(service_name=service_name, recipe=exec_recipe)
    return result["output"]


def extract_json_key(plan, service_name, filename, key):
    """
    Extract a specific key from a JSON file, located in a service, and return its value.
    Note: We don't use the extract feature here because there are issues when trying to retrieve nested JSON keys from a list.

    Args:
        service_name (string): The name of the service.
        filename (string): The name of the JSON file to read from.
        key (string): The key to extract from the JSON file.

    Returns:
        The extracted value, as a string.
    """
    exec_recipe = ExecRecipe(
        command=["/bin/sh", "-c", "jq -r '{}' {} | tr -d '\n'".format(key, filename)]
    )
    result = plan.exec(service_name=service_name, recipe=exec_recipe)
    return result["output"]


def sed(plan, service_name, expression, filename):
    """
    Replace a value in a file using a sed expression within a specified service.

    Args:
        service_name (string): The name of the service.
        expression (string): The expression for replacing the value.
        filename (string): The name of the file to modify.
    """
    exec_recipe = ExecRecipe(
        command=["/bin/sh", "-c", "sed -i '{}' {}".format(expression, filename)]
    )
    plan.exec(service_name=service_name, recipe=exec_recipe)
