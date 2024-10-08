#!/bin/bash

# Variables
root_folder=""
checksum_file="checksum.json"
all_successful=true

# Step 1: Go to the root folder
cd "$root_folder" || { echo "Failed to enter $root_folder"; exit 1; }

# Step 2: Read JSON and iterate over each architecture (ignoring version and description)
archs=$(jq -r 'keys | map(select(. != "run_id"))[]' "$checksum_file")

for arch in $archs; do
    # Extract the file path and expected checksum for the current architecture
    file_path=$(jq -r --arg arch "$arch" '.[$arch].path' "$checksum_file")
    expected_checksum=$(jq -r --arg arch "$arch" '.[$arch].checksum' "$checksum_file")

    # Step 3: Calculate the hash of the file (SHA-256 used as an example)
    if [ -f "$file_path" ]; then
        file_hash=$(sha256sum "$file_path" | awk '{ print $1 }')

        # Step 4: Compare the checksums
        if [ "$file_hash" == "$expected_checksum" ]; then
            echo "The checksums match for $arch ($file_path)."
        else
            echo "The checksums do not match for $arch ($file_path)."
            all_successful=false
        fi
    else
        echo "File not found for $arch: $file_path"
        all_successful=false
    fi
done

# Print success message if all checksums matched
if $all_successful; then
    echo "All checksums match."
else
    echo "There were errors verifying some checksums."
    exit 1
fi