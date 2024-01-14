PRIO_ENVS := $(shell env | sort | uniq)

export PRIO_ENVS := $(PRIO_ENVS)