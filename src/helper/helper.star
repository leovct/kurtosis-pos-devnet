def run(plan, validators, mnemonic):
    validator_keys_path = "/var/lib/validators"
    helper = plan.add_service(
        name="helper",
        config=ServiceConfig(
            image=ImageBuildSpec(image_name="helper", build_context_dir="."),
            env_vars={
                "VALIDATORS_COUNT": "{}".format(validators),
                "MNEMONIC": mnemonic,
                "DATA_PATH": validator_keys_path,
            },
        ),
    )
    response = plan.wait(
        service_name="helper",
        recipe=ExecRecipe(command=["cat", "/tmp/done"]),
        field="code",
        assertion="==",
        target_value=0,
    )

    validator_keys = plan.store_service_files(
        service_name="helper",
        src="{}/*".format(validator_keys_path),
        name="validators_keys",
    )
    return validator_keys
