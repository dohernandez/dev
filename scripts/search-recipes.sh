#!/bin/bash

IFS=' ' read -r -a PLUGINS <<< "$PLUGINS"

this="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source "$this/recipe.sh"

# Start parsing from the main Makefile
excludes=$(parse_makefile Makefile)

# Loop over each plugin
for plugin_key in "${PLUGINS[@]}"; do
    makefiles_path=$(eval "echo \${PLUGIN_${plugin_key}_MAKEFILES_PATH}")
    main_file=$(eval "echo \${PLUGIN_${plugin_key}_MAIN}")

    excludes="$excludes $(parse_makefile "${makefiles_path}/${main_file}")"
done

# Collect files from EXTEND_DEVGO_PATH
EXTEND_DEVGO_FILES=()

while IFS= read -r -d '' file; do
  EXTEND_DEVGO_FILES+=("$file")
done < <(find "$EXTEND_DEVGO_PATH/makefiles" -name "*.mk" -print0)

printf "dev:\n"
printf_recipes "$excludes" "${EXTEND_DEVGO_FILES[*]}"

# Loop over each plugin
for plugin_key in "${PLUGINS[@]}"; do
    # Collect files from PLUGIN_MAKEFILES_PATH
    PLUGIN_MAKEFILES_FILES=()

    PLUGIN_MAKEFILES_PATH=$(eval "echo \${PLUGIN_${plugin_key}_MAKEFILES_PATH}")

    while IFS= read -r -d '' file; do
      PLUGIN_MAKEFILES_FILES+=("$file")
    done < <(find "$PLUGIN_MAKEFILES_PATH" -name "*.mk" -print0)

    plugin_name=$(eval "echo \${PLUGIN_${plugin_key}_NAME}")

    printf "\n"
    printf "${plugin_name}:\n"

    printf_recipes "$excludes" "${PLUGIN_MAKEFILES_FILES[*]}"
done

