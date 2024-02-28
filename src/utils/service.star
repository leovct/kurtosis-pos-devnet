def define_completion_file_ready_condition(
    completion_file_path="/tmp/done", interval="10s", timeout="5m"
):
    """
    Define a ready condition that waits for a completion file to be created.

    Args:
        completion_file_path (str): The path to the file indicating readiness.
        interval (str): The time interval between readiness checks.
        timeout (str): The maximum time to wait for the ready condition.

    Returns:
        ReadyCondition: A ready condition object.
    """
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
