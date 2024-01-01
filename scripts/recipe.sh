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
    local package="$1"
    local afiles="$2"
    local excludes="$3"

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

            # Check if the recipe require another recipe to add to the description.
            requires=$(awk '/^#- require - /{print $0}' $file)

            comma=false

            if [[ -n $requires ]]; then
              desc="$desc (requires:"
              # Loop over each required recipe
              while IFS= read -r line; do
                  plugin=$(echo "$line" | awk '{n=split($0,a,"/"); a[n]=""; for(i=1;i<n;i++) printf("%s%s",a[i],i<n-1?"/":"")}' | sed 's/^#- require - //')
                  recipe=$(echo "$line" | awk -F'/' '{print $NF}')

                  if [ "$comma" = true ]; then
                      desc="$desc,"
                  fi

                  if [ "$plugin" == "self" ]; then
                    plugin=$package
                  fi

                  desc=$(printf "$desc %s/%s" "$plugin" "$recipe")

                  comma=true
              done <<< "$requires"
              desc="$desc)"
            fi

            # Print recipe name and description
            printf "  \033[33m%-20s\033[0m   %s\n" \
                    						`basename $file .mk` "$desc";

            # Print targets and descriptions
            awk -F':' '/^##/ {desc=$0} /^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$)/ {print desc "\n" $1}' $file | \
            while read -r line; do
                if [[ $line == "##"* ]]; then
                    # This line is a description
                    desc=${line#"## "}
                else
                    # This line is a target
                    if [[ -n $desc ]]; then
                        printf "    \033[32m%-20s\033[0m %s\n" "$line" "$desc"
                        unset desc
                    fi
                fi
            done

        fi
    done
}