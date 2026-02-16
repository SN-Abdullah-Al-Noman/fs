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
# 2. Shallow sync of everything
# ----------------------------
# Use --depth=1 to save space and speed up CI
repo sync -c -j8 --no-tags --depth=1

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
# 6. Copy binaries to workspace
# ----------------------------
mkdir -p "$GITHUB_WORKSPACE/bin"
cp "$HOST_OUT/gen_file_contexts" "$GITHUB_WORKSPACE/bin/"
cp "$HOST_OUT/gen_fs_config" "$GITHUB_WORKSPACE/bin/"

echo "Binaries built and copied to $GITHUB_WORKSPACE/bin"
echo "gen_file_contexts: $GITHUB_WORKSPACE/bin/gen_file_contexts"
echo "gen_fs_config: $GITHUB_WORKSPACE/bin/gen_fs_config"
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
