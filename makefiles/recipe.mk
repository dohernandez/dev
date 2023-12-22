GO ?= go

FILES := $(foreach file, $(EXTEND_DEVGO_PATH)/makefiles/*.mk $(PLUGIN_MAKEFILES_FILES), \
	$(wildcard $(file)) \
)

## List all available recipes
list-recipes:
	@echo "Available recipe to enable:"
	@bash $(EXTEND_DEVGO_SCRIPTS)/list-recipes.sh


## Enable a recipe into Makefile
enable-recipe:
	@echo "Enabling recipe: $(NAME)"
	@NAME=$(NAME) \
	DEVGO_PATH=$(DEVGO_PATH) \
	EXTEND_DEVGO_PATH=$(EXTEND_DEVGO_PATH) \
	bash $(EXTEND_DEVGO_SCRIPTS)/enable-recipe.sh











