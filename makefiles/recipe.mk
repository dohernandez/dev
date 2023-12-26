GO ?= go

## Search all available recipes
search-recipes:
	@echo "Search for available recipe to enable"
	@bash $(EXTEND_DEVGO_SCRIPTS)/search-recipes.sh


## Enable a recipe into Makefile, use make enable-recipe PACKAGE=package_name NAME=recipe_name
enable-recipe:
	@echo "Enabling recipe: $(PACKAGE) $(NAME)"
	@NAME=$(NAME) \
	PLUGIN=$(PACKAGE) \
	bash $(EXTEND_DEVGO_SCRIPTS)/enable-recipe.sh


## List the recipes enabled into Makefile
list-recipes:
	@echo "List of recipes enabled:"
	@bash $(EXTEND_DEVGO_SCRIPTS)/list-recipes.sh


## Disable a recipe from Makefile, use make disable-recipe NAME=recipe_name
disable-recipe:
	@echo "Disabling recipe: $(NAME)"
	@NAME=$(NAME) \
	bash $(EXTEND_DEVGO_SCRIPTS)/disable-recipe.sh








