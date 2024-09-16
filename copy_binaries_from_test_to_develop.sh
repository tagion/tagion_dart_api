#!/bin/bash

TEST_DIR_PATH="/Users/piss/builds/tagion_dart_api/binaries_test"
DEVELOPMENT_DIR_PATH="/Users/piss/builds/tagion_dart_api/development"

ANDROID_ARM64_PATH="android/src/main/jniLibs/arm64-v8a/libtauonapi.so"
ANDROID_ARMEABI_PATH="android/src/main/jniLibs/armeabi-v7a/libtauonapi.so"
ANDROID_x86_64_PATH="android/src/main/jniLibs/x86-64/libtauonapi.so"
IOS_ARM_PATH="ios/libtauonapi.xcframework/ios-arm64/libtauonapi.framework/libtauonapi"
IOS_x86_64_PATH="ios/libtauonapi.xcframework/ios-x86_64-simulator/libtauonapi.framework/libtauonapi"

# Function to create directory if it doesn't exist
create_dir_if_not_exists() {
  local dir_path=$(dirname "$1")
  
  if [ ! -d "$dir_path" ]; then
    mkdir -p "$dir_path"
    echo "Created directory: $dir_path"
  fi
}

# Function to copy files and log the modification date
copy_and_log() {
  local src=$1
  local dest=$2

  # Check if the source file exists
  if [ ! -f "$src" ]; then
    echo "Source file $src does not exist. Exiting."
    exit 1
  fi

  # Create destination directory if it doesn't exist
  create_dir_if_not_exists "$dest"
  
  # Copy the file
  cp "$src" "$dest"
  
  # Check if the copy was successful and log the modification date
  if [ $? -eq 0 ]; then
    echo "Updated $dest - Modified on: $(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$dest")"
  else
    echo "Failed to update $dest"
    exit 1
  fi
}

copy_and_log "$TEST_DIR_PATH/$ANDROID_ARM64_PATH" "$DEVELOPMENT_DIR_PATH/$ANDROID_ARM64_PATH"
copy_and_log "$TEST_DIR_PATH/$ANDROID_ARMEABI_PATH" "$DEVELOPMENT_DIR_PATH/$ANDROID_ARMEABI_PATH"
copy_and_log "$TEST_DIR_PATH/$ANDROID_x86_64_PATH" "$DEVELOPMENT_DIR_PATH/$ANDROID_x86_64_PATH"
copy_and_log "$TEST_DIR_PATH/$IOS_ARM_PATH" "$DEVELOPMENT_DIR_PATH/$IOS_ARM_PATH"
copy_and_log "$TEST_DIR_PATH/$IOS_x86_64_PATH" "$DEVELOPMENT_DIR_PATH/$IOS_x86_64_PATH"

echo "All binaries have been successfully copied from test to development"