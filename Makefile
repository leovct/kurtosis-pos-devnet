##@ Help

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "Usage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Lint

.PHONY: lint
lint: ## Run linters.
	kurtosis lint --format
	yamllint --config-file .yamllint.yml .
	find . -type f -name 'Dockerfile*' | sort | xargs -I {} hadolint --config .hadolint.yml {}
	find . -type f -name '*.sh' | sort | xargs -I {} shellcheck {}
