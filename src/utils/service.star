def wait_for_service_to_be_ready(
    plan, service_name, completion_file_path="/tmp/done", timeout="5m"
):
    """
    Wait for a service to be ready by checking if a completion file has been created.

    Args:
        service_name (string): The name of the service.
        completion_file_path (string): The path to the file indicating service readiness.
        timeout (string): The maximum time to wait for service readiness.
    """
    exec_recipe = ExecRecipe(
        command=["/bin/sh", "-c", "cat {}".format(completion_file_path)]
    )
    plan.wait(
        service_name=service_name,
        recipe=exec_recipe,
        field="code",
        assertion="==",
        target_value=0,
        timeout=timeout,
    )
