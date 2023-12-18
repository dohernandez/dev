#!/bin/bash

EXTEND_DEVGO_PATH=${EXTEND_DEVGO_PATH}

# Specify the directory to search for .mk files
SEARCH_DIR=$(realpath "${EXTEND_DEVGO_PATH}/makefiles")

# Create an associative array (map) in Bash
RECEIPT_MAP=()

# Iterate over the .mk files in the search directory
for file in "$SEARCH_DIR"/*.mk; do
    # Extract the filename without extension
    filename=$(basename -- "$file")
    filename_noext="${filename%.*}"

    # Create the map entry with the relative path and filename
    key="$filename_noext"
    value="\$(EXTEND_DEVGO_PATH)/makefiles/$filename"

    # Add the entry to the map
    RECEIPT_MAP+=("$key=$value")
done

# Print the map entries
for entry in "${RECEIPT_MAP[@]}"; do
    echo "$entry"
done
