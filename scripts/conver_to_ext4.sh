#!/bin/bash

Version="2.1"

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <img_path> [destination_directory]"
    echo "Example: $0 /home/user/images/system.img /mnt/tmp"
    exit 1
fi

IMG_PATH="$1"
DEST_DIR="${2:-$(pwd)}"  # default to current directory if not specified
IMG_NAME_BASE=$(basename "$IMG_PATH" .img)
NEW_IMG_NAME="$DEST_DIR/ext4_${IMG_NAME_BASE}.img"

# Check if the image exists
if [ ! -f "$IMG_PATH" ]; then
    echo "Image not found: $IMG_PATH"
    exit 1
fi

# Clean previous mounts
umount "$DEST_DIR/$IMG_NAME_BASE" 2>/dev/null
rm -rf "$DEST_DIR/$IMG_NAME_BASE"
umount "$DEST_DIR/${IMG_NAME_BASE}_mount" 2>/dev/null
rm -rf "$DEST_DIR/${IMG_NAME_BASE}_mount"

# Create mount point and mount original image read-only
mkdir -p "$DEST_DIR/${IMG_NAME_BASE}_mount"
mount -o loop,ro "$IMG_PATH" "$DEST_DIR/${IMG_NAME_BASE}_mount"

# Calculate size for new image (+10% buffer)
MOUNT_SIZE=$(du -sb "$DEST_DIR/${IMG_NAME_BASE}_mount" | awk '{print int($1 * 1.1)}')
echo "Mounted image size: ${MOUNT_SIZE} bytes"

# Create new ext4 image
dd if=/dev/zero of="$NEW_IMG_NAME" bs=1 count=0 seek=$MOUNT_SIZE
mkfs.ext4 -F -b 4096 "$NEW_IMG_NAME"

# Mount new ext4 image
mkdir -p "$DEST_DIR/$IMG_NAME_BASE"
mount -o loop "$NEW_IMG_NAME" "$DEST_DIR/$IMG_NAME_BASE"

# Copy content from original image
cp -arv "$DEST_DIR/${IMG_NAME_BASE}_mount"/* "$DEST_DIR/$IMG_NAME_BASE"

# Unmount new image
umount "$DEST_DIR/$IMG_NAME_BASE"
rm -rf "$DEST_DIR/$IMG_NAME_BASE"

# Unmount original image
umount "$DEST_DIR/${IMG_NAME_BASE}_mount"
rm -rf "$DEST_DIR/${IMG_NAME_BASE}_mount"

echo ""
echo "Conversion completed."
echo "New image created: $NEW_IMG_NAME with size: $MOUNT_SIZE bytes."
