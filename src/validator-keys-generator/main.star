def run(plan, validators, mnemonic, data_path):
    name = "validator-keys-generator"
    plan.add_service(
        name,
        config=ServiceConfig(
            image=ImageBuildSpec(image_name=name, build_context_dir="."),
            env_vars={
                "VALIDATORS_COUNT": "{}".format(validators),
                "MNEMONIC": mnemonic,
                "DATA_PATH": data_path,
            },
        ),
    )
    response = plan.wait(
        service_name=name,
        recipe=ExecRecipe(command=["cat", "/tmp/done"]),
        field="code",
        assertion="==",
        target_value=0,
        timeout="5m",
    )
    return plan.store_service_files(
        service_name=name,
        src="{}/*".format(data_path),
        name="validator-keys",
    )
