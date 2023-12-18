#!/bin/bash

this_path=$(dirname "$0")

# Get receipts from bool64-dev-receipts.sh
RECEIPT_MAP_BOOL64=$(DEVGO_PATH=${DEVGO_PATH} bash $this_path/bool64-dev-receipts.sh)

# Get receipts from dev-receipts.sh
RECEIPT_MAP_DEV=$(EXTEND_DEVGO_PATH=${EXTEND_DEVGO_PATH} bash $this_path/dev-receipts.sh)

# Combine the maps
RECEIPT_MAP="$RECEIPT_MAP_BOOL64 $RECEIPT_MAP_DEV"

found=false

for entry in $RECEIPT_MAP; do
    key=$(echo $entry | cut -d= -f1)
    value=$(echo $entry | cut -d= -f2)

    if [ "$key" = "$NAME" ]; then
        found=true
        receipt_path=$value
        break
    fi
done

if [ "$found" = "true" ]; then
    awk '/# End extra receipts here./{print "-include '"$receipt_path"'"; print; next} 1' Makefile > Makefile.tmp && mv Makefile.tmp Makefile
    echo "Receipt $NAME enabled successfully."
else
    echo "Receipt $NAME not found or already enable."
fi