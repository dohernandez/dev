#!/usr/bin/env bash

# checking if docker is available.
if ! command -v docker >/dev/null; then
  echo "[FAIL] docker is not installed."; \
fi

