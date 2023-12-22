GO ?= go

FILES := $(foreach file, $(EXTEND_DEVGO_PATH)/makefiles/*.mk $(PLUGIN_MAKEFILES_FILES), \
	$(wildcard $(file)) \
)

## Search all available recipes
search-recipes:
	@echo "Search for available recipe to enable"
	@bash $(EXTEND_DEVGO_SCRIPTS)/search-recipes.sh


## Enable a recipe into Makefile
enable-recipe:
	@echo "Enabling recipe: $(PLUGIN) $(NAME)"
	@NAME=$(NAME) \
	PLUGIN=$(PLUGIN) \
	bash $(EXTEND_DEVGO_SCRIPTS)/enable-recipe.sh


## List the recipes enabled into Makefile
list-recipes:
	@echo "List of recipes enabled:"
	@bash $(EXTEND_DEVGO_SCRIPTS)/list-recipes.sh


## Disable a recipe from Makefile
disable-recipe:
	@echo "Disabling recipe: $(NAME)"
	@NAME=$(NAME) \
	bash $(EXTEND_DEVGO_SCRIPTS)/disable-recipe.sh








