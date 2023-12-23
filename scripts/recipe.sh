#!/bin/bash

# Recursive function to parse Makefile and included files
parse_makefile() {
    local makefile="$1"

    local recipes=()

    while IFS= read -r line; do
        # Replace occurrences of placeholders with actual values
        line=$(echo "$line" | sed "s#\$(EXTEND_DEVGO_PATH)#${EXTEND_DEVGO_PATH}#g")

        # Loop over each plugin
        for plugin_key in "${PLUGINS[@]}"; do
            # Replace occurrences of placeholders with actual values
            variable_name="PLUGIN_${plugin_key}_MAKEFILES_PATH"
            placeholder="\$(PLUGIN_${plugin_key}_MAKEFILES_PATH)"
            replacement="${!variable_name}"

            line=$(echo "$line" | sed "s#${placeholder}#${replacement}#g")
        done

        # Check if the file is excluded
        if [[ $line == "\$(MAKEFILE_INCLUDES)" ]]; then
            # TODO: Try to get content of MAKEFILE_INCLUDES
            continue
        fi

        file="$line"

        if [ -f $file ]; then
            recipes+=("$file")

            more=$(parse_makefile $file)

            if [ -n "$more" ]; then
                recipes+=("$more")
            fi
        fi

    done < <(awk '/-include[[:space:]]/{print $2}' $makefile)

    echo "${recipes[*]}"
}

printf_recipes() {
    local excludes="$1"
    local afiles="$2"

    # Convert the space-separated string to an array
    IFS=' ' read -r -a files <<< "$afiles"

    # Iterate over .mk files and print those not in excludes.txt
    for file in "${files[@]}"; do
        if [ `basename "${file}" .mk` != "base" ] && \
           [ `basename "${file}" .mk` != "main" ] && \
           [ `basename "${file}" .mk` != "help" ] && \
            ! echo $excludes | grep -q $file; then
            desc=""

            # Read the first line
            desc_line=$(head -n 1 "$file")

            # Check if the line starts with '###'
            if [[ $desc_line == "#-## "* ]]; then
                # Remove leading '###' and trim extra spaces
                desc=$(echo "$desc_line" | sed 's/^#-## //' | tr -s ' ')
            fi

#            printf "  \033[32m%-20s\033[0m %s\n" \
#                    						`basename $file .mk` "$desc";

            printf "  \033[33m%-20s\033[0m %s\n" \
                    						`basename $file .mk` "$desc";

        fi
    done
}