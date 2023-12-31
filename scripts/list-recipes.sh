#!/bin/bash

IFS=' ' read -r -a PLUGINS <<< "$PLUGINS"

this="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source "$this/recipe.sh"

# Start parsing from the main Makefile
enables=$(parse_makefile "$MAKEFILE_FILE")

excludes="${EXTEND_DEVGO_PATH}/makefiles/main.mk ${EXTEND_DEVGO_PATH}/makefiles/recipe.mk"

printf_recipes "" "$enables" "$excludes"