ENV_KEYS := $(shell printenv | awk -F= '{print $$1}' | tr '\n' ' ')

export ENV_KEYS := $(ENV_KEYS)
