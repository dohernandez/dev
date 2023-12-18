GO ?= go

FILES := $(wildcard $(DEVGO_PATH)/makefiles/*.mk $(EXTEND_DEVGO_PATH)/makefiles/*.mk)

## List all available recipes
list-recipes:
	@echo "Available recipe to enable:"
	@PWD=$(PWD) \
	EXTEND_DEVGO_PATH=$(EXTEND_DEVGO_PATH) \
	DEVGO_PATH=$(DEVGO_PATH) \
	FILES="$(FILES)" \
	bash $(EXTEND_DEVGO_SCRIPTS)/list-recipes.sh


## Enable a recipe into Makefile
enable-recipe:
	@echo "Enabling recipe: $(NAME)"
	@NAME=$(NAME) \
	DEVGO_PATH=$(DEVGO_PATH) \
	EXTEND_DEVGO_PATH=$(EXTEND_DEVGO_PATH) \
	bash $(EXTEND_DEVGO_SCRIPTS)/enable-recipe.sh











