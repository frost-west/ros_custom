#!/bin/bash

log "Including Magisk in the pending build process..."

# Save the current directory just in case
CURRENTDIR=$(pwd)

# Determine the directory this script was called from
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Define the name of the directory that Magisk-related patches are stored
PATCH_DIR=magisk-patches

# Change to the build directory and apply Magisk patches to the build tree
cd ${BUILD_DIR}
for patchfile in ${SCRIPT_DIR}/${PATCH_DIR}/*.patch
do
	patch -p1 --no-backup-if-mismatch < ${patchfile}
done

log "Magisk patches have been applied to the build tree"

# Determine the latest version of Magisk
MAGISK_VERSION=$(curl -s https://api.github.com/repos/topjohnwu/Magisk/releases | jq -r '.[0] | .tag_name')

log "Latest version of Magisk is ${MAGISK_VERSION}, downloading Magisk..."

# Download the version of Magisk that was previously detected
wget https://github.com/topjohnwu/Magisk/releases/download/${MAGISK_VERSION}/Magisk-${MAGISK_VERSION}.zip -O magisk-latest.zip
mkdir -p magisk-latest
unzip -d magisk-latest magisk-latest.zip
rm -rf magisk-latest.zip

# Make x86 magiskboot executable for later kernel patching
chmod +x ${BUILD_DIR}/magisk-latest/x86/magiskboot

# Verify that Magisk was downloaded
MAGISK_VERSION=$(grep -a -P 'Magisk(.*)v(.*)\.' ${BUILD_DIR}/magisk-latest/arm/magiskinit64 | sed 's|.*v|v|' | sed 's|).*|)|')

log "Magisk ${MAGISK_VERSION} downloaded to ${BUILD_DIR}/magisk-latest"
log "Magisk should now be included in this RattlesnakeOS build once the build is complete."
log "NOTE: Magisk can only be installed via an OTA update, NOT as a factory image."
log "If you intend to install this build as a factory image, please terminate this build now and start it again without Magisk."

# Change back to the starting directory
cd ${CURRENTDIR}
