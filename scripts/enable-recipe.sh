#!/bin/bash

[ -z "$NAME" ] && echo "NAME is required" && exit 1
[ -z "$PLUGIN" ] && PLUGIN=""

IFS=' ' read -r -a PLUGINS <<< "$PLUGINS"

# Collect recipes
RECIPE_MAP=()

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

        if [ "$PLUGIN_NAME" != "$PLUGIN" ]; then
            continue
        fi

        PLUGIN_MAKEFILES_PATH=$(eval "echo \${PLUGIN_${plugin_key}_MAKEFILES_PATH}")

        while IFS= read -r -d '' file; do
            # Extract the filename without extension
            filename=$(basename -- "$file")
            filename_noext="${filename%.*}"

            # Create the map entry with the relative path and filename
            key="$filename_noext"
            value="\$(PLUGIN_${plugin_key}_MAKEFILES_PATH)/$filename"

            # Add the entry to the map
            RECIPE_MAP+=("$key=$value")
        done < <(find "$PLUGIN_MAKEFILES_PATH" -name "*.mk" -print0)
    done
fi

found=false

for entry in "${RECIPE_MAP[@]}"; do
    key=$(echo $entry | cut -d= -f1)
    value=$(echo $entry | cut -d= -f2)

    if [ "$key" = "$NAME" ]; then
        found=true
        recipe_relative_path=$value
        break
    fi
done

if [ "$found" = "true" ]; then
    # Check if the recipe is already included
    if grep -q $recipe_relative_path Makefile; then
        echo "Recipe $PLUGIN $NAME already enabled."

        exit 0
    fi

    #Check if the recipe require another recipe
    if [ -z "$PLUGIN" ]; then
        # Replace occurrences of placeholders with actual values
        recipe_path=$(echo "$recipe_relative_path" | sed "s#\$(EXTEND_DEVGO_PATH)#${EXTEND_DEVGO_PATH}#g")
    else
        # Replace occurrences of placeholders with actual values
        variable_name="PLUGIN_${plugin_key}_MAKEFILES_PATH"
        placeholder="\$(PLUGIN_${plugin_key}_MAKEFILES_PATH)"
        replacement="${!variable_name}"

        recipe_path=$(echo "$recipe_relative_path" | sed "s#${placeholder}#${replacement}#g")
    fi

    while IFS= read -r line; do
        plugin=$(echo "$line" | awk '{n=split($0,a,"/"); a[n]=""; for(i=1;i<n;i++) printf("%s%s",a[i],i<n-1?"/":"")}' | sed 's/^#- require - //')
        recipe=$(echo "$line" | awk -F'/' '{print $NF}')

        result=$(PLUGINS=$PLUGINS PLUGIN=$plugin NAME=$recipe bash $EXTEND_DEVGO_PATH/scripts/enable-recipe.sh)

        if [[ "$result" =~ ^Recipe\ .*\ enabled\ successfully\.$ ]] || [[ "$result" =~ ^Recipe\ .*\ already\ enabled\.$ ]]; then
            continue
        else
            echo "$result"
            exit 0
        fi

    done < <(awk '/^#- require - /{print $0}' $recipe_path)

    awk '/# End extra recipes here./{print "-include '"$recipe_relative_path"'"; print; next} 1' Makefile > Makefile.tmp && mv Makefile.tmp Makefile
    echo "Recipe $PLUGIN $NAME enabled successfully."
else
    echo "Recipe $PLUGIN $NAME not found."
    exit 1
fi
