blkid -o value -s TYPE odm.img

export MKFS_EROFS="$(pwd)/bin/erofs-utils/mkfs.erofs"

chmod +x "$MKFS_EROFS"

resize2fs
