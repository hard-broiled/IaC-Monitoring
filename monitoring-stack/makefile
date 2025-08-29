# Virtual environment setup
VENV := .venv
PYTHON := python

# Directories
PY_SRC := metrics-service
TERRAFORM_SRC := terraform
DOCKERFILE := docker/Dockerfile
YAML_DIRS := grafana alertmanager
VENV_ACTIVATE := . $(VENV)/bin/activate #source $(VENV)/bin/activate
CONTAINERS := prometheus grafana alertmanager metrics-service

#-----------------------------------------------------------------

venv:
	$(PYTHON) -m venv $(VENV)
	bash -c "$(VENV_ACTIVATE) && pip install --upgrade pip"
	bash -c "$(VENV_ACTIVATE) && pip install -r requirements-dev.txt"
	bash -c "$(VENV_ACTIVATE) && pre-commit install"

check-venv:
	@test -d $(VENV) || (echo "Virtualenv not found, run 'make venv' first" && exit 1)

#-----------------------------------------------------------------

# Format Terraform configs
lint-terraform-fmt:
	terraform fmt -recursive -check $(TERRAFORM_SRC)

# Lint Terraform with tflint
lint-terraform:
	tflint $(TERRAFORM_SRC)
	terraform validate $(TERRAFORM_SRC)

# Lint Dockerfile with hadolint
lint-docker:
	hadolint $(DOCKERFILE)

# Lint YAML configs
lint-yaml: check-venv
	bash -c "$(VENV_ACTIVATE) && yamllint $(YAML_DIRS)"

# Lint + format Python
lint-python: check-venv
	bash -c "$(VENV_ACTIVATE) && $(VENV)/bin/black --check $(PY_SRC)"
	bash -c "$(VENV_ACTIVATE) && $(VENV)/bin/flake8 $(PY_SRC)"
	bash -c "$(VENV_ACTIVATE) && $(VENV)/bin/mypy $(PY_SRC)"

#-----------------------------------------------------------------
# Chained Lint
lint: lint-terraform-fmt lint-terraform lint-docker lint-yaml lint-python
	@echo "All lint checks passed."

    # terraform fmt -recursive
    # tflint terraform/
    # hadolint docker/Dockerfile || true
    # yamllint grafana/ alertmanager/
    # black --check python-metrics/
    # flake8 python-metrics/

# Dev target to bootstrap venv + run chained lint
dev: venv check-venv #lint
	@echo "Dev environment is ready!"

# Format all auto-fixable files
format:
	terraform fmt -recursive $(TERRAFORM_SRC)
	bash -c "$(VENV_ACTIVATE) && $(VENV)/bin/black $(PY_SRC)"

#-----------------------------------------------------------------

# Clean up venv and temp files
clean:
	rm -rf $(VENV) __pycache__ .mypy_cache .pytest_cache
	find . -name "*.pyc" -delete
