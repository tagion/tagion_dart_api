#!/bin/bash

# Variables
root_folder=""
checksum_file="checksums.json"
temp_file=$(mktemp)

# Step 1: Go to the root folder
cd "$root_folder" || { echo "Failed to enter $root_folder"; exit 1; }

# Step 2: Read JSON and iterate over each architecture (ignoring version and description)
archs=$(jq -r 'keys | map(select(. != "version" and . != "description"))[]' "$checksum_file")

for arch in $archs; do
    # Extract the file path for the current architecture
    file_path=$(jq -r --arg arch "$arch" '.[$arch].path' "$checksum_file")

    # Step 3: Calculate the hash of the file (SHA-256 used as an example)
    if [ -f "$file_path" ]; then
        file_hash=$(sha256sum "$file_path" | awk '{ print $1 }')

        # Step 4: Update the checksum field in the JSON object
        jq --arg arch "$arch" --arg new_checksum "$file_hash" '(.[$arch].checksum) |= $new_checksum' "$checksum_file" > "$temp_file" && mv "$temp_file" "$checksum_file"
    else
        echo "File not found for $arch: $file_path"
        exit 1
    fi
done

echo "All checksums have been updated."