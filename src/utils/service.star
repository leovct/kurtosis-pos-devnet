# Stop and start again a service.
def restart_service(plan, service_name):
    plan.stop_service(service_name)
    plan.start_service(service_name)


# Read and retrieve the content of a file, within a service.
# Note: It automatically removes newline characters.
def read_file_from_service(plan, service_name, filename):
    exec_recipe = ExecRecipe(
        command=["/bin/sh", "-c", "cat {} | tr -d '\n'".format(filename)]
    )
    result = plan.exec(service_name=service_name, recipe=exec_recipe)
    return result["output"]


# Extract a specific key from a JSON file, within a service, using jq.
# Note: jq must be installed.
def extract_json_key_from_service_with_jq(plan, service_name, filename, key):
    exec_recipe = ExecRecipe(
        command=["/bin/sh", "-c", "jq -r '{}' {} | tr -d '\n'".format(key, filename)]
    )
    result = plan.exec(service_name=service_name, recipe=exec_recipe)
    return result["output"]


# Extract a specific key from a JSON file, within a service.
# Note: jq does not need to be installed.
def extract_json_key_from_service_without_jq(plan, service_name, filename, expression):
    exec_recipe = ExecRecipe(
        command=["/bin/sh", "-c", "cat {}".format(filename)],
        extract={"value": "fromjson | {}".format(expression)},
    )
    result = plan.exec(service_name=service_name, recipe=exec_recipe)
    return result["extract.value"]


# Replace a value in a file using a sed expression, within a service.
def sed_file_in_service(plan, service_name, expression, filename):
    exec_recipe = ExecRecipe(
        command=["/bin/sh", "-c", "sed -i '{}' {}".format(expression, filename)]
    )
    plan.exec(service_name=service_name, recipe=exec_recipe)


# Define a ready condition that waits for a completion file to be created.
def define_completion_file_ready_condition(
    completion_file_path="/tmp/done", interval="10s", timeout="5m"
):
    exec_recipe = ExecRecipe(
        command=["/bin/sh", "-c", "cat {}".format(completion_file_path)]
    )
    return ReadyCondition(
        recipe=exec_recipe,
        field="code",
        assertion="==",
        target_value=0,
        interval=interval,
        timeout=timeout,
    )
