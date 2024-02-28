service_utils = import_module("../utils/service.star")

SERVICE_NAME = "validator-keys-generator"


def run(plan, validator_count, mnemonic, data_path):
    start_validator_keys_generator(plan, validator_count, mnemonic, data_path)
    return copy_validator_keys(plan, data_path)


def start_validator_keys_generator(plan, validator_count, mnemonic, data_path):
    ready_condition = service_utils.define_completion_file_ready_condition()
    plan.add_service(
        name=SERVICE_NAME,
        config=ServiceConfig(
            image=ImageBuildSpec(image_name=SERVICE_NAME, build_context_dir="."),
            env_vars={
                "VALIDATOR_COUNT": "{}".format(validator_count),
                "MNEMONIC": mnemonic,
                "DATA_PATH": data_path,
            },
            ready_conditions=ready_condition,
        ),
    )


def copy_validator_keys(plan, data_path):
    return plan.store_service_files(
        service_name=SERVICE_NAME,
        src="{}/*".format(data_path),
        name="validator-keys",
    )
