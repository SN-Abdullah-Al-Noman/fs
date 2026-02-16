#!/bin/bash
set -e

# ----------------------------
# Variables
# ----------------------------
AOSP_DIR="$HOME/aosp_min"
AOSP_BRANCH="android-12.0.0_r1"
HOST_OUT="$AOSP_DIR/out/host/linux-x86/bin"
mkdir -p "$AOSP_DIR"

# ----------------------------
# 1. Initialize repo
# ----------------------------
cd "$AOSP_DIR"
repo init -u https://android.googlesource.com/platform/manifest -b $AOSP_BRANCH

# ----------------------------
# 2. Sync only required directories
# ----------------------------
repo sync -c -j8 build
repo sync -c -j8 system/sepolicy/selinux
repo sync -c -j8 system/core/fs_mgr
repo sync -c -j8 external/selinux
repo sync -c -j8 system/core/libnativehelper

# ----------------------------
# 3. Setup build environment
# ----------------------------
source build/envsetup.sh
lunch aosp_arm64-eng

# ----------------------------
# 4. Build gen_file_contexts
# ----------------------------
cd system/sepolicy/selinux
mmm gen_file_contexts

# ----------------------------
# 5. Build gen_fs_config
# ----------------------------
cd ../../core/fs_mgr
mmm .

# ----------------------------
# 6. Add binaries to PATH
# ----------------------------
echo
