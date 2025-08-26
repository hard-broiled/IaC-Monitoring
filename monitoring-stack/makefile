# Virtual environment setup
VENV := .venv
PYTHON := python3

# Directories
PY_SRC := metrics-service
TERRAFORM_SRC := terraform
DOCKERFILE := docker/Dockerfile
YAML_DIRS := grafana alertmanager
VENV_ACTIVATE := . $(VENV)/bin/activate

#-----------------------------------------------------------------

venv:
	$(PYTHON) -m venv $(VENV)
	$(VENV_ACTIVATE) && pip install --upgrade pip
	$(VENV_ACTIVATE) && pip install -r requirements-dev.txt
	$(VENV_ACTIVATE) && pre-commit install

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
lint-yaml:
	$(VENV_ACTIVATE) && yamllint $(YAML_DIRS)

# Lint + format Python
lint-python:
	$(VENV_ACTIVATE) && black --check $(PY_SRC)
	$(VENV_ACTIVATE) && flake8 $(PY_SRC)
	$(VENV_ACTIVATE) && mypy $(PY_SRC)

#-----------------------------------------------------------------

check-venv:
	@test -d $(VENV) || (echo "Virtualenv not found, run 'make venv' first" && exit 1)

lint: lint-terraform-fmt lint-terraform lint-docker lint-yaml lint-python
    @echo "All lint checks passed."

    # terraform fmt -recursive
    # tflint terraform/
    # hadolint docker/Dockerfile || true
    # yamllint grafana/ alertmanager/
    # black --check python-metrics/
    # flake8 python-metrics/

# Format all auto-fixable files
format:
	terraform fmt -recursive $(TERRAFORM_SRC)
	$(VENV_ACTIVATE) && black $(PY_SRC)

#-----------------------------------------------------------------

# Clean up venv and temp files
clean:
	rm -rf $(VENV) __pycache__ .mypy_cache .pytest_cache
	find . -name "*.pyc" -delete
