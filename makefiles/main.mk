GO ?= go
PWD := $(shell pwd)

EXTEND_DEVGO_PATH ?= $(PWD)
EXTEND_DEVGO_MAKEFILES ?= $(EXTEND_DEVGO_PATH)/makefiles
EXTEND_DEVGO_SCRIPTS ?= $(EXTEND_DEVGO_PATH)/scripts

export EXTEND_DEVGO_PATH := $(EXTEND_DEVGO_PATH)
export EXTEND_DEVGO_MAKEFILES := $(EXTEND_DEVGO_MAKEFILES)
export EXTEND_DEVGO_SCRIPTS := $(EXTEND_DEVGO_SCRIPTS)

MAKEFILE_FILE ?= Makefile
export MAKEFILE_FILE := $(MAKEFILE_FILE)

NOPRUNE_FILE ?= noprune.go
export NOPRUNE_FILE := $(NOPRUNE_FILE)

GOMOD_FILE ?= go.mod
export GOMOD_FILE := $(GOMOD_FILE)

# TODO: makefile.yml should be relative to allow use by default the defined in this repo
EXTEND_MANIFEST_FILE ?= $(EXTEND_DEVGO_MAKEFILES)/makefile.yml
export EXTEND_MANIFEST_FILE := $(EXTEND_MANIFEST_FILE)

#-# Get plugins from dev package
EXTEND_PLUGIN_EXPORTS := $(shell GOMOD_FILE=$(GOMOD_FILE) PLUGIN_MANIFEST_FILE=$(EXTEND_MANIFEST_FILE) bash $(EXTEND_DEVGO_SCRIPTS)/load_plugins.sh)

EXTEND_PLUGINS = $(filter PLUGINS=%,$(EXTEND_PLUGIN_EXPORTS))
EXTEND_PLUGINS := $(subst PLUGINS=,,$(EXTEND_PLUGINS))

EXTEND_PLUGIN_EXPORTS := $(patsubst PLUGINS=%,,$(EXTEND_PLUGIN_EXPORTS))

#-# Set plugins from dev package
$(foreach _export,$(EXTEND_PLUGIN_EXPORTS), \
	$(eval export $(_export)) \
)

EXTEND_PLUGINS := $(subst :, ,$(EXTEND_PLUGINS))

#-# Get plugins from package
PLUGIN_MANIFEST_FILE ?= makefile.yml
export PLUGIN_MANIFEST_FILE := $(PLUGIN_MANIFEST_FILE)

#-# Check if makefile.yml exists
ifneq ($(wildcard $(PLUGIN_MANIFEST_FILE)),)
	#-# Get plugins
	PLUGIN_EXPORTS := $(shell GOMOD_FILE=$(GOMOD_FILE) PLUGIN_MANIFEST_FILE=$(PLUGIN_MANIFEST_FILE) bash $(EXTEND_DEVGO_SCRIPTS)/load_plugins.sh)
endif

PACKAGE_PLUGINS = $(filter PLUGINS=%,$(PLUGIN_EXPORTS))
PACKAGE_PLUGINS := $(subst PLUGINS=,,$(PACKAGE_PLUGINS))

PLUGIN_EXPORTS := $(patsubst PLUGINS=%,,$(PLUGIN_EXPORTS))

#-# Set plugins
$(foreach _export,$(PLUGIN_EXPORTS), \
	$(eval export $(_export)) \
)

PACKAGE_PLUGINS := $(subst :, ,$(PACKAGE_PLUGINS))

$(foreach plugin_key,$(EXTEND_PLUGINS), \
	$(eval PACKAGE_PLUGINS += $(plugin_key)) \
)

PACKAGE_PLUGINS := $(sort $(EXTEND_PLUGINS) $(filter-out $(EXTEND_PLUGINS),$(PACKAGE_PLUGINS)))

#-# Expert plugin if it is not exported
ifeq ($(PLUGINS),)
	export PLUGINS := $(PACKAGE_PLUGINS)
else
	override PLUGINS := $(PACKAGE_PLUGINS)
endif

#-# Include plugins main makefile
MAKEFILE_INCLUDES := $(foreach plugin_key,$(PLUGINS), \
	$(if $(PLUGIN_$(plugin_key)_MAIN), \
    	$(subst =, ,$(PLUGIN_$(plugin_key)_MAKEFILES_PATH)/$(PLUGIN_$(plugin_key)_MAIN)), \
    ) \
)

#-# Fix the bug in bool64/dev for env var DEVGO_PATH and DEVGO_SCRIPTS and go mod is in different path
$(foreach plugin_key,$(PLUGINS), \
	$(if $(filter BOOL64DEV,$(plugin_key)), \
    	$(eval export DEVGO_PATH=$(PLUGIN_$(plugin_key)_VENDOR_PATH)) \
    	$(eval export DEVGO_SCRIPTS=$(DEVGO_PATH)/scripts) \
    ) \
)

-include $(MAKEFILE_INCLUDES)

#-# Patching bug in bool64/dev for help target
#-# awk: cmd. line:2: warning: regexp escape sequence `\_' is not a known regexp operator
-include $(EXTEND_DEVGO_MAKEFILES)/help.mk

-include $(EXTEND_DEVGO_PATH)/makefiles/recipe.mk
-include $(EXTEND_DEVGO_PATH)/makefiles/version.mk
