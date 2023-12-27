#!/bin/bash

# Ask for input

default_package="local"
read -p "Enter the package name (local): " package
package=${package:-$default_package}
echo "Using package: $package"

default_folder="makefiles"
read -p "Enter the makefiles folder ($default_folder): " folder
folder=${folder:-$default_folder}
echo "Using makefiles folder: $folder"

read -p "Enter the main file (press enter to skip): " main
if [ -n "$main" ]; then
    echo "Using main file: $main"
fi

# Set the plugin name
if [ "$package" != "local" ]; then
    name=$(echo $package | cut -d'/' -f2-)
else
    name=$package
fi

# Check if the plugin manifest file exists, otherwise create it
if [ ! -f "$PLUGIN_MANIFEST_FILE" ]; then
  touch "$PLUGIN_MANIFEST_FILE"
fi

# Check if a plugin with the same name already exists
plugin_exists=$(yq e '.plugins[] | select(.name == "'"${name}"'")' "$PLUGIN_MANIFEST_FILE")
if [ -n "$plugin_exists" ]; then
    echo "Error: A plugin with the name $name already exists."
    exit 1
fi

# Start building the plugin string
plugin_string="[{\"name\": \"${name}\""

# Add package to the plugin string if package is not local
if [ "$package" != "local" ]; then
    plugin_string+=", \"package\": \"${package}\""
fi

plugin_string+=", \"makefiles_path\": \"${folder}\""

# Add main to the plugin string if main is not empty
if [ -n "$main" ]; then
    plugin_string+=", \"main\": \"${main}\""
fi

# Close the plugin string
plugin_string+="}]"

# Append the new plugin entry to makefile.yml
yq e -i ".plugins += $plugin_string" "$PLUGIN_MANIFEST_FILE"

echo "Plugin $package added to $PLUGIN_MANIFEST_FILE"

# Adding plugin package to the noprune.go file
if [ "$package" != "local" ]; then
    # Functions to extract imports from the file

    new_imports=(
        "_ \"$package\""
    )

    # Join new imports with line breaks and prepend a tabulator
    new_imports_joined=$(IFS=$'\n'; echo "${new_imports[*]/#/$'\t'}")

    imports=$new_imports_joined

    # prev_imports when file exists
    if [[ -f $NOPRUNE_FILE ]]; then
        # Extract existing imports inside parentheses
        prev_imports=$(awk '/^import \(/,/\)/ { if (/^[_[:space:]]*"/) print $0 }' "$NOPRUNE_FILE")

        # Check if there were imports inside parentheses in the original file
        if [[ -z $prev_imports ]]; then
            # Existing import without parentheses
            prev_imports=$(awk '/^import / {gsub(/^[[:space:]]*import /, "\t"); print $0} /^import \(/,/\)/ {gsub(/^[[:space:]]*/, ""); print $0}' "$NOPRUNE_FILE")
        fi
    fi

    if [[ -n $prev_imports ]]; then
        imports=$prev_imports$'\n'$imports
    fi

    cat <<EOL > "$NOPRUNE_FILE"
//go:build never
// +build never

package noprune

import (
$imports
)
EOL

    echo "Plugin $package added to $NOPRUNE_FILE"
fi