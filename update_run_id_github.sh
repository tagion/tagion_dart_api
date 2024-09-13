#!/bin/bash

# Check if RUN_ID is passed as an argument
if [ -n "$1" ]; then
    RUN_ID=$1
    echo "Using provided RUN_ID: $RUN_ID"

    # Update checksum.json with the [RUN_ID]
    jq --arg run_id "$RUN_ID" '.run_id = $run_id' checksum.json > checksum.tmp && mv checksum.tmp checksum.json
    echo "Updated checksum.json with run_id: $RUN_ID"
else
    # Prompt for RUN_ID input if not provided
    read -p "Enter RUN_ID: " INPUT_RUN_ID

    if [ -z "$INPUT_RUN_ID" ]; then
        echo "Can't run without RUN_ID. Exiting..."
        exit 1
    else
        RUN_ID=$INPUT_RUN_ID
        echo "Using provided RUN_ID: $RUN_ID"
        # Update checksum.json with the [RUN_ID]
        jq --arg run_id "$RUN_ID" '.run_id = $run_id' checksum.json > checksum.tmp && mv checksum.tmp checksum.json
        echo "Updated checksum.json with run_id: $RUN_ID"
    fi
fi