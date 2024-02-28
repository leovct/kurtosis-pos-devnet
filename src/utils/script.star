def define_execute_script_command(path):
    """
    Define a command to grant execution permissions and execute a script.

    Args:
        path (str): The path to the script.

    Returns:
        The command in a list, ready to be used as a service command.
    """
    return ["chmod +x {0} && sh {0}".format(path)]
