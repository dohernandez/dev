#!/bin/bash

this_path=$(dirname "$0")

# Get recipes from bool64-dev-recipes.sh
RECIPE_MAP_BOOL64=$(DEVGO_PATH=${DEVGO_PATH} bash $this_path/bool64-dev-recipes.sh)

# Get recipes from dev-recipes.sh
RECIPE_MAP_DEV=$(EXTEND_DEVGO_PATH=${EXTEND_DEVGO_PATH} bash $this_path/dev-recipes.sh)

# Combine the maps
RECIPE_MAP="$RECIPE_MAP_BOOL64 $RECIPE_MAP_DEV"

found=false

for entry in $RECIPE_MAP; do
    key=$(echo $entry | cut -d= -f1)
    value=$(echo $entry | cut -d= -f2)

    if [ "$key" = "$NAME" ]; then
        found=true
        recipe_path=$value
        break
    fi
done

if [ "$found" = "true" ]; then
    awk '/# End extra recipes here./{print "-include '"$recipe_path"'"; print; next} 1' Makefile > Makefile.tmp && mv Makefile.tmp Makefile
    echo "Recipe $NAME enabled successfully."
else
    echo "Recipe $NAME not found or already enable."
fi