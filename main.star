rootchain = import_module("./src/rootchain.star")
heimdall = import_module("./src/heimdall.star")


def run(plan):
    rootchain.run(plan)
    heimdall.run(plan)
