GO ?= go
PWD := $(shell pwd)
GOPATH := $(realpath $(shell $(GO) env GOPATH))

ifneq ($(wildcard ./vendor),)
    modVendor := -mod=vendor
endif

MODULE_NAME := $(shell test -f go.mod && GO111MODULE=on $(GO) list $(modVendor) -m)

EXTEND_DEVGO_PATH ?= $(PWD)
EXTEND_DEVGO_SCRIPTS ?= $(EXTEND_DEVGO_PATH)/scripts

export EXTEND_DEVGO_PATH := $(EXTEND_DEVGO_PATH)
export EXTEND_DEVGO_SCRIPTS := $(EXTEND_DEVGO_SCRIPTS)

MAKEFILE_FILE ?= Makefile

export MAKEFILE_FILE := $(MAKEFILE_FILE)

# TODO: makefile.yml should be relative to allow use by default the defined in this repo
PLUGIN_MANIFEST_FILE ?= makefile.yml

#-# Check if makefile.yml exists
ifneq ($(wildcard $(PLUGIN_MANIFEST_FILE)),)
	#-# Get plugins
	EXPORTS := $(shell bash $(EXTEND_DEVGO_SCRIPTS)/load_plugins.sh)
endif

#-# Set plugins
$(foreach _export,$(EXPORTS), \
	$(eval export $(_export)) \
)

PLUGINS := $(subst :, ,$(PLUGINS))

#-# Include plugins main makefile
MAKEFILE_INCLUDES := $(foreach plugin_key,$(PLUGINS), \
	$(if $(PLUGIN_$(plugin_key)_MAIN), \
    	$(subst =, ,$(PLUGIN_$(plugin_key)_MAKEFILES_PATH)/$(PLUGIN_$(plugin_key)_MAIN)), \
    ) \
)

-include $(MAKEFILE_INCLUDES)