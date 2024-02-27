def run(plan, validators, mnemonic):
    name = "validator-keys-generator"
    validator_keys_path = "/etc/validators"
    plan.add_service(
        name,
        config=ServiceConfig(
            image=ImageBuildSpec(image_name=name, build_context_dir="."),
            env_vars={
                "VALIDATORS_COUNT": "{}".format(validators),
                "MNEMONIC": mnemonic,
                "DATA_PATH": validator_keys_path,
            },
        ),
    )
    response = plan.wait(
        service_name=name,
        recipe=ExecRecipe(command=["cat", "/tmp/done"]),
        field="code",
        assertion="==",
        target_value=0,
    )
    return plan.store_service_files(
        service_name=name,
        src="{}/*".format(validator_keys_path),
        name="validator-keys",
    )
