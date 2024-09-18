#!/bin/bash

CHECKSUM_FILE="checksum.json"

# Step 1: Create a temporary folder
ROOT_DIR=$(pwd)
TEMP_DIR="$ROOT_DIR/temp_$(date +%s)"
mkdir -p $TEMP_DIR
echo "Created temporary directory: $TEMP_DIR"

# Step 2: Download artifacts from GitHub's last action to that folder
OWNER="tagion"
REPO="tagion"
WORKFLOW_ID="57584524" # The ID of the mainflow

# List of artifact names to download
ARTIFACT_NAMES=(
  "aarch64-linux-android"
  "armv7a-linux-android"
  "x86_64-linux-android"
  "arm64-apple-ios"
  "x86_64-apple-ios-simulator"
)

# Check if RUN_ID is passed as an argument
if [ -n "$1" ]; then
    RUN_ID=$1
    echo "Using provided RUN_ID: $RUN_ID"
else
    # Get RUN_ID from the checksum.json file
    RUN_ID=$(jq -r '.run_id' "$CHECKSUM_FILE")
    echo "Using RUN_ID from checksum.json: $RUN_ID"
fi

# Get the list of artifacts for the most recent workflow run
ARTIFACTS=$(curl -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/$OWNER/$REPO/actions/runs/$RUN_ID/artifacts")

# Download each specified artifact
for ARTIFACT_NAME in "${ARTIFACT_NAMES[@]}"; do
    ARTIFACT_ID=$(echo $ARTIFACTS | jq -r ".artifacts[] | select(.name == \"$ARTIFACT_NAME\") | .id")
    if [ -n "$ARTIFACT_ID" ]; then
        curl -L -H "Authorization: token $GITHUB_TOKEN" \
            -H "Accept: application/vnd.github.v3+json" \
            "https://api.github.com/repos/$OWNER/$REPO/actions/artifacts/$ARTIFACT_ID/zip" \
            -o $TEMP_DIR/$ARTIFACT_NAME.zip
        unzip $TEMP_DIR/$ARTIFACT_NAME.zip -d $TEMP_DIR/$ARTIFACT_NAME
    else
        echo "Artifact $ARTIFACT_NAME not found"
        # Delete the temporary folder
        rm -rf $TEMP_DIR
        echo "Deleted temporary directory: $TEMP_DIR"
        exit 1
    fi
done

# Step 3: Copy the binaries to the desired location
# ANDROID
# aarch64-linux-android
mkdir -p ./android/src/main/jniLibs/arm64-v8a
cp $TEMP_DIR/aarch64-linux-android/libtauonapi.so ./android/src/main/jniLibs/arm64-v8a/libtauonapi.so
# armv7a-linux-android
mkdir ./android/src/main/jniLibs/armeabi-v7a
cp $TEMP_DIR/armv7a-linux-android/libtauonapi.so ./android/src/main/jniLibs/armeabi-v7a/libtauonapi.so
# x86_64-linux-android
mkdir ./android/src/main/jniLibs/x86-64
cp $TEMP_DIR/x86_64-linux-android/libtauonapi.so ./android/src/main/jniLibs/x86-64/libtauonapi.so

# IOS
# arm64-apple-ios
# copy
cp $TEMP_DIR/arm64-apple-ios/libtauonapi.dylib ./ios/libtauonapi.xcframework/ios-arm64/libtauonapi.framework/libtauonapi.dylib
# change directory
cd ./ios/libtauonapi.xcframework/ios-arm64/libtauonapi.framework
# modify the binary
lipo -create libtauonapi.dylib -output libtauonapi
# update path
install_name_tool -id '@rpath/libtauonapi.framework/libtauonapi' libtauonapi
# check
otool -L libtauonapi
# remove unmodified binary
rm libtauonapi.dylib
cd -

# x86_64-apple-ios-simulator
# copy
cp $TEMP_DIR/x86_64-apple-ios-simulator/libtauonapi.dylib ./ios/libtauonapi.xcframework/ios-x86_64-simulator/libtauonapi.framework/libtauonapi.dylib
# change directory
cd ./ios/libtauonapi.xcframework/ios-x86_64-simulator/libtauonapi.framework
# modify the binary
lipo -create libtauonapi.dylib -output libtauonapi
# update path
install_name_tool -id '@rpath/libtauonapi.framework/libtauonapi' libtauonapi
# check
otool -L libtauonapi
# remove unmodified binary
rm libtauonapi.dylib
cd -

# Step 4: Delete the temporary folder
rm -rf $TEMP_DIR
echo "Deleted temporary directory: $TEMP_DIR"

# Step 5: Run a separate script to update the checksums in the checksum.json file
chmod +x ./update_checksum.sh
./update_checksum.sh

# Step 6: Update the run_id field in the checksum.json file
chmod +x ./update_run_id_github.sh
./update_run_id_github.sh $RUN_ID