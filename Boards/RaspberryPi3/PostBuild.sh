#!/bin/bash
TARGET=DEBUG
TARGET_TOOLS=GCC47

BUILD_ROOT=$WORKSPACE/Build/FirmwarePkg/"$TARGET"_"$TARGET_TOOLS"
TMP_DIR=$BUILD_ROOT/Temp
BOOT_IMAGE=kernel.img

UEFI_BIN_PI2=$WORKSPACE/Build/FirmwarePkg/"$TARGET"_"$TARGET_TOOLS"/FV/PI2BOARD_EFI.fd
UEFI_BIN_PI3=$WORKSPACE/Build/FirmwarePkg/"$TARGET"_"$TARGET_TOOLS"/FV/PI3BOARD_EFI.fd
TMP_DIR=/tmp

mkdir $TMP_DIR


echo -e "Composing $BOOT_IMAGE...\n"

#
# Build startup code
#
$WORKSPACE/FirmwarePkg/Scripts/Startup.sh $WORKSPACE/FirmwarePkg/Scripts/RaspberryPi.S 0x8000 $TMP_DIR/startup.bin

#
# Generate final firmware image
#
if [ "$DOUBLE" == true ]; then
    dd if=/dev/zero of=$TMP_DIR/pad.bin bs=1024 count=160 conv=notrunc
    cat $TMP_DIR/startup.bin $UEFI_BIN_PI2 $TMP_DIR/pad.bin $UEFI_BIN_PI3 > $BUILD_ROOT/$BOOT_IMAGE
else
    dd if=/dev/zero of=$TMP_DIR/pad.bin bs=1024 count=1024 conv=notrunc
    cat $TMP_DIR/startup.bin $TMP_DIR/pad.bin $UEFI_BIN_PI3  > $BUILD_ROOT/$BOOT_IMAGE
fi
echo -e "\nDone Composing combined $BOOT_IMAGE\n"

#
# Clean up
#
rm -rf $TMP_DIR

echo -e "Created combined $BOOT_IMAGE $TARGET at $BUILD_ROOT/$BOOT_IMAGE\n"
