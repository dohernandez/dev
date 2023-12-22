#!/bin/bash

[ -z "$NAME" ] && echo "NAME is required" && exit 1
[ -z "$PLUGIN" ] && PLUGIN=""

# Collect recipes
RECIPE_MAP=()

echo "PLUGIN=$PLUGIN"
echo "NAME=$NAME"
echo "PLUGINS=$PLUGINS[@]"

if [ -z "$PLUGIN" ]; then
  while IFS= read -r -d '' file; do
      # Extract the filename without extension
      filename=$(basename -- "$file")
      filename_noext="${filename%.*}"

      # Create the map entry with the relative path and filename
      key="$filename_noext"
      value="\$(EXTEND_DEVGO_PATH)/makefiles/$filename"

      # Add the entry to the map
      RECIPE_MAP+=("$key=$value")
  done < <(find "$EXTEND_DEVGO_PATH/makefiles" -name "*.mk" -print0)
else
    # Loop over each plugin
    for plugin_key in "${PLUGINS[@]}"; do
        PLUGIN_NAME=$(eval "echo \${PLUGIN_${plugin_key}_NAME}")

        echo "PLUGIN_NAME=$PLUGIN_NAME"

        if [ "$PLUGIN_NAME" != "$PLUGIN" ]; then
            continue
        fi

        echo "This is the plugin"

        PLUGIN_MAKEFILES_PATH=$(eval "echo \$(PLUGIN_${plugin_key}_MAKEFILES_PATH)")

        echo "PLUGIN_MAKEFILES_PATH=$PLUGIN_MAKEFILES_PATH"

        while IFS= read -r -d '' file; do
            # Extract the filename without extension
            filename=$(basename -- "$file")
            filename_noext="${filename%.*}"

            echo "filename=$filename"
            echo "filename_noext=$filename_noext"

            # Create the map entry with the relative path and filename
            key="$filename_noext"
            value="\${PLUGIN_${plugin_key}_MAKEFILES_PATH}/$filename"

            # Add the entry to the map
            RECIPE_MAP+=("$key=$value")
        done < <(find "$PLUGIN_MAKEFILES_PATH" -name "*.mk" -print0)
    done
fi

echo "RECIPE_MAP=${RECIPE_MAP[@]}"

found=false

for entry in "${RECIPE_MAP[@]}"; do
    key=$(echo $entry | cut -d= -f1)
    value=$(echo $entry | cut -d= -f2)

    echo "key=$key"
    echo "value=$value"

    if [ "$key" = "$NAME" ]; then
        found=true
        recipe_path=$value
        break
    fi
done

if [ "$found" = "true" ]; then
    awk '/# End extra recipes here./{print "-include '"$recipe_path"'"; print; next} 1' Makefile > Makefile.tmp && mv Makefile.tmp Makefile
    echo "Recipe $recipe_name enabled successfully."
else
    # Check if the recipe is already included
    if grep -q $recipe_path Makefile; then
        echo "Recipe $recipe_name already enabled."

        return 0
    fi

    echo "Recipe $recipe_name not found or already enable."
fi
