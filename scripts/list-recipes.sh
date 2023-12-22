#!/bin/bash

# Initialize counter and excludes file
excludes=""

# Recursive function to parse Makefile and included files
parse_makefile() {
    while IFS= read -r line; do
        line=$(echo "$line" | sed "s#\$(EXTEND_DEVGO_PATH)#${EXTEND_DEVGO_PATH}#g")

        # Loop over each plugin
        for plugin_key in "${PLUGINS[@]}"; do
            # Replace occurrences of placeholders with actual values
            variable_name="PLUGIN_${plugin_key}_MAKEFILES_PATH"
            placeholder="\$(PLUGIN_${plugin_key}_MAKEFILES_PATH)"
            replacement="${!variable_name}"

            line=$(echo "$line" | sed "s#${placeholder}#${replacement}#g")
        done

        file="$line"

        # Check if the file is excluded
#        if grep -q $file ["\$(MAKEFILE_INCLUDES)"]; then
        if [[ $file == "\$(MAKEFILE_INCLUDES)" ]]; then
            continue
        fi

        excludes="$excludes $file"

        if [ -f $file ]; then
            parse_makefile $file
        fi

    done < <(awk '/-include[[:space:]]/{print $2}' $1)
}

printfRecipes() {
    local files=("$@")

    # Iterate over .mk files and print those not in excludes.txt
    for file in "${files[@]}"; do
        if [ `basename $file .mk` != "base" ] && \
           [ `basename $file .mk` != "main" ] && \
           [ `basename $file .mk` != "help" ] && \
            ! echo $excludes | grep -q $file; then
            desc=""

            # Read the first line
            desc_line=$(head -n 1 "$file")

            # Check if the line starts with '###'
            if [[ $desc_line == "#-## "* ]]; then
                # Remove leading '###' and trim extra spaces
                desc=$(echo "$desc_line" | sed 's/^#-## //' | tr -s ' ')
            fi

            printf "  \033[32m%-20s\033[0m %s\n" \
                    						`basename $file .mk` "$desc";

        fi
    done
}

# Start parsing from the main Makefile
parse_makefile Makefile

# Loop over each plugin
for plugin_key in "${PLUGINS[@]}"; do
    makefiles_path=$(eval "echo \${PLUGIN_${plugin_key}_MAKEFILES_PATH}")
    main_file=$(eval "echo \${PLUGIN_${plugin_key}_MAIN}")

    parse_makefile "${makefiles_path}/${main_file}"
done

# Collect files from EXTEND_DEVGO_PATH
EXTEND_DEVGO_FILES=()

while IFS= read -r -d '' file; do
  EXTEND_DEVGO_FILES+=("$file")
done < <(find "$EXTEND_DEVGO_PATH/makefiles" -name "*.mk" -print0)

printf "dev:\n"
printfRecipes "${EXTEND_DEVGO_FILES[@]}"

# Collect files from PLUGIN_MAKEFILES_PATH

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

    printfRecipes "${PLUGIN_MAKEFILES_FILES[@]}"
done

