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











