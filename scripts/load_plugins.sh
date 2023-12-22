#!/bin/bash

[ -z "$PLUGIN_MANIFEST_FILE" ] && PLUGIN_MANIFEST_FILE="makefile.yml"
[ -z "$VENDOR_PATH" ] && VENDOR_PATH="./vendor"

if [ -d "$VENDOR_PATH" ]; then
    modVendor="-mod=vendor"
fi

PLUGINS=()

# Check if the manifest file exists
if [ -f "$PLUGIN_MANIFEST_FILE" ]; then
    yaml_content=$(cat "$PLUGIN_MANIFEST_FILE")

    PLUGIN_NAMES=$(echo "$yaml_content" | yq eval '.plugins[].name' -)

    # Iterate over plugins
    for plugin_name in $PLUGIN_NAMES; do
        plugin_package=$(echo "$yaml_content" | yq eval '.plugins[] | select(.name=="'$plugin_name'").package' -)
        plugin_makefiles_path=$(echo "$yaml_content" | yq eval '.plugins[] | select(.name=="'$plugin_name'").makefiles_path' -)
        plugin_main=$(echo "$yaml_content" | yq eval '.plugins[] | select(.name=="'$plugin_name'").main' -)

        # Replace 'null' with an empty string only if var is exactly "null"
        if [ "$plugin_package" = "null" ]; then
            plugin_package=${plugin_package//null/}
        fi

        # Replace 'null' with an empty string only if var is exactly "null"
        if [ "$plugin_makefiles_path" = "null" ]; then
            plugin_makefiles_path=${plugin_makefiles_path//null/}
        fi

        # Replace 'null' with an empty string only if var is exactly "null"
        if [ "$plugin_main" = "null" ]; then
            plugin_main=${plugin_main//null/}
        fi

        plugin_key=$(echo "$plugin_name" | tr -d -C '[:alnum:]_' | tr '[:lower:]' '[:upper:]')

        echo "PLUGIN_${plugin_key}_NAME"="$plugin_name"
        echo "PLUGIN_${plugin_key}_PACKAGE"="$plugin_package"
        echo "PLUGIN_${plugin_key}_MAIN"="$plugin_main"

        plugin_vendor_path=""
        plugin_makefiles_full_path=""

        if [[ -n "$plugin_package" ]]; then
            if [[ -d "$VENDOR_PATH" && -d "$VENDOR_PATH/$plugin_package" ]]; then
                plugin_vendor_path="$VENDOR_PATH/$plugin_package"
            fi

            if [ -z "$plugin_vendor_path" ]; then
                plugin_vendor_path=$(GO111MODULE=on go list ${modVendor} -f '{{.Dir}}' -m "$plugin_package")

                if [ -z "$plugin_vendor_path" ]; then
                    plugin_vendor_path=$(export GO111MODULE=on && go get "$plugin_package" && go list -f '{{.Dir}}' -m "$plugin_package")
                fi
            fi

            # Build the full path to the makefiles
            if [[ -n "$plugin_package"  ]]; then
                if [[ -n "$plugin_makefiles_path" ]]; then
                    plugin_makefiles_full_path="$plugin_package/$plugin_makefiles_path"
                else
                    plugin_makefiles_full_path="$plugin_package"
                fi
            else
                plugin_makefiles_full_path="$plugin_makefiles_path"
            fi
        fi

        echo "PLUGIN_${plugin_key}_VENDOR_PATH"="$plugin_vendor_path"

        if [[ -z "$plugin_makefiles_full_path" ]]; then
            plugin_makefiles_full_path="."
        fi

        if [[ -n "$plugin_makefiles_path" ]]; then
            plugin_makefiles_full_path="$plugin_makefiles_path"
        fi

        if [[ -n "$plugin_vendor_path" ]]; then
            plugin_makefiles_full_path="$plugin_vendor_path/$plugin_makefiles_path"
        fi

        echo "PLUGIN_${plugin_key}_MAKEFILES_PATH"="$plugin_makefiles_full_path"

        PLUGINS+=("$plugin_key")
    done
fi

IFS=:
echo "PLUGINS=${PLUGINS[*]}"