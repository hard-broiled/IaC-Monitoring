#!/usr/bin/env bash
set -e

# Create venv if not exists
if [ ! -d ".venv" ]; then
  python3 -m venv .venv
fi

# Activate venv
source .venv/bin/activate

# Upgrade pip
pip install --upgrade pip

# Install requirements
pip install -r requirements-dev.txt

echo "Virtual environment ready. Run 'source .venv/bin/activate' to use."
