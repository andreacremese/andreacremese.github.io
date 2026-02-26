#!/bin/sh
# Simple setup script to install pre-commit hooks

if ! command -v pre-commit >/dev/null 2>&1; then
  echo "[ERROR] pre-commit is not installed. Please install it with 'pip install pre-commit' or 'brew install pre-commit'."
  exit 1
fi

pre-commit install

echo "pre-commit hooks installed."
