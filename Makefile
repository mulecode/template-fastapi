$(VERBOSE).SILENT:
.DEFAULT_GOAL := help

COMPOSE_RUN_PYTHON = docker compose run --no-deps --rm python
COMPOSE_RUN_PYTHON_MAKE = docker compose run --no-deps --entrypoint "make" --rm python

MODULE_NAME := $(notdir $(CURDIR))
MODULE_PATH := /opt/app

COVERAGE := 90


.PHONY: setup
setup: ## Installs persistable python virtual env and pyproject.toml
	$(COMPOSE_RUN_PYTHON_MAKE) -C $(MODULE_PATH) _setup

_setup:
	@echo "Setting up python environment"
	@if [ ! -d ./venv/ ]; then \
  		echo "VENV not found - Creating new virtual env"; \
		python3 -m venv ./venv; \
		source ./venv/bin/activate; \
		python3 -m pip install --upgrade pip==24.2; \
	fi
	@./venv/bin/python -m pip install --upgrade pip
	@./venv/bin/pip install '.[test]'

.PHONY: version
version: ## Prints current version
	$(COMPOSE_RUN_PYTHON_MAKE) -C $(MODULE_PATH) _version

_version:
	@./venv/bin/python --version
	@./venv/bin/pip --version

.PHONY: test
test: ## Run Python tests
	$(COMPOSE_RUN_PYTHON_MAKE) -C $(MODULE_PATH) _test

_test: ## Run Python tests
	@./venv/bin/python -m black python/ --check
	@./venv/bin/python -m black tests/ --check
	@./venv/bin/python -m pylint python/
	@if [ -d ./out/coverage/ ]; then rm -Rf ./out/coverage/; fi
	@./venv/bin/python -m pytest -vv --cov=python/ tests/ --cov-fail-under=$(COVERAGE) --cov-report term --cov-report xml:out/coverage/coverage.xml

.PHONY: package
package: ## Package Python dependencies and python modules
	$(COMPOSE_RUN_PYTHON_MAKE) -C $(MODULE_PATH) _package

_package:
	@echo "Packaging python modules"
	@./venv/bin/python -m pip install --upgrade build

####################################################################################
##@ Running
####################################################################################
.PHONT: run
run: ## Run Python application
	docker compose up --build fastapi --remove-orphans

.PHONT: run_dev
run_dev: ## Run Python application in dev mode
	docker compose up --build fastapi-dev --remove-orphans

.PHONY: run_test
run_test: PROTOCOL=http
run_test: PORT=8080
run_test: HEALTH_API=/api/v1/health
run_test: HOST_URL=localhost
run_test: ## Quick check if application is running
	@curl -i -X GET "$(PROTOCOL)://$(HOST_URL):$(PORT)$(HEALTH_API)" -H "accept: application/json"

####################################################################################
##@ Developing
####################################################################################
.PHONY: formatter
formatter: ## Code formatter
	$(COMPOSE_RUN_PYTHON_MAKE) -C $(MODULE_PATH) _formatter

_formatter:
	@./venv/bin/python -m black python/
	@./venv/bin/python -m black tests/

####################################################################################
##@ Utils
####################################################################################
.PHONY: help
help: ## Display this help
	@awk \
	  'BEGIN { \
	    FS = ":.*##"; printf "\nUsage:\n"\
			"  make \033[36m<target>\033[0m\n" \
	  } /^[a-zA-Z_-]+:.*?##/ { \
	    printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 \
	  } /^##@/ { \
	    printf "\n\033[1m%s\033[0m\n", substr($$0, 5) \
	  } ' $(MAKEFILE_LIST)
