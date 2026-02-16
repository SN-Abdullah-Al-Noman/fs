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
# 0. Install required packages (Ubuntu/Debian)
# ----------------------------
echo "Installing required packages..."
sudo apt update
sudo apt install -y git-core gnupg flex bison gperf build-essential \
    zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 \
    x11proto-core-dev libx11-dev lib32z1-dev ccache \
    libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig python3 python3-pip repo

# ----------------------------
# Setup latest repo launcher
# ----------------------------
mkdir -p $HOME/bin
curl https://storage.googleapis.com/git-repo-downloads/repo > $HOME/bin/repo
chmod a+x $HOME/bin/repo
export PATH="$HOME/bin:$PATH"

# Initialize AOSP
cd "$AOSP_DIR"
repo init -u https://android.googlesource.com/platform/manifest -b $AOSP_BRANCH

# Shallow sync with new repo
repo sync -c -j8 --no-tags


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

echo "✅ Binaries built and copied to $GITHUB_WORKSPACE/bin"
echo "gen_file_contexts: $GITHUB_WORKSPACE/bin/gen_file_contexts"
echo "gen_fs_config: $GITHUB_WORKSPACE/bin/gen_fs_config"
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
