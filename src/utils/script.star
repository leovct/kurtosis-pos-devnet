# Define a command to grant execution permissions and execute a script.
def define_execute_script_command(script_path):
    return ["chmod +x {0} && sh {0}".format(script_path)]
