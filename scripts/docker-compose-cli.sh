#!/usr/bin/env bash

# checking if docker is available.
if ! command -v docker-compose >/dev/null; then
  echo "[FAIL] docker-compose is not installed."; \
fi

