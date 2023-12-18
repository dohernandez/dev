#!/bin/bash

# Initialize counter and excludes file
i=1
excludes=""

# Recursive function to parse Makefile and included files
parse_makefile() {
    while IFS= read -r line; do
        replaced=`echo $line | sed 's#$(EXTEND_DEVGO_PATH)#'${EXTEND_DEVGO_PATH}'#g' | sed 's#$(DEVGO_PATH)#'${PWD}/${DEVGO_PATH}'#g'`

        file=`echo $replaced`

        excludes="$excludes $file"

        if [ -f $file ]; then
            parse_makefile $file
        fi

    done < <(awk '/-include[[:space:]]/{print $2}' $1)
}

# Start parsing from the main Makefile
parse_makefile Makefile

# Iterate over .mk files and print those not in excludes.txt
for file in $FILES; do
    if [ `basename $file .mk` != "base" ] && ! echo $excludes | grep -q $file; then
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

        i=$((i+1))
    fi
done
