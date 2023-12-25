#!/bin/bash

[ -z "$NAME" ] && echo "NAME is required" && exit 1

IFS=' ' read -r -a PLUGINS <<< "$PLUGINS"

this="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source "$this/recipe.sh"

# Start parsing from the main Makefile
enables=$(parse_makefile "$MAKEFILE_FILE")

# Convert the space-separated string to an array
IFS=' ' read -r -a recipes <<< "$enables"

found=false

# Loop over each plugin
for recipe in "${recipes[@]}"; do
    if [ `basename "${recipe}" .mk` = "$NAME" ]; then
        found=true
        break
    fi
done

if [ "$found" = false ]; then
    echo "Recipe not found"
    exit 1
fi

sed '/# Start extra recipes here./,/# End extra recipes here./{/'"$NAME"'/d;}' "$MAKEFILE_FILE" > "$MAKEFILE_FILE".tmp && mv "$MAKEFILE_FILE".tmp "$MAKEFILE_FILE"
