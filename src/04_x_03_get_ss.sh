#!/bin/sh

echo "*** GET SHADOWSOCKS BEGIN ***"

SRC_DIR=$(pwd)

# Grab everything after the '=' character.
DOWNLOAD_URL=$(grep -i ^SHADOWSOCKS_SOURCE_URL .config | cut -f2 -d'=')

# Grab everything after the last '/' character.
ARCHIVE_FILE=${DOWNLOAD_URL##*/}

# Read the 'USE_LOCAL_SOURCE' property from '.config'
USE_LOCAL_SOURCE="$(grep -i ^USE_LOCAL_SOURCE .config | cut -f2 -d'=')"

if [ "$USE_LOCAL_SOURCE" = "true" -a ! -f $SRC_DIR/source/$ARCHIVE_FILE  ] ; then
  echo "Source bundle $SRC_DIR/source/$ARCHIVE_FILE is missing and will be downloaded."
  USE_LOCAL_SOURCE="false"
fi

cd source

if [ ! "$USE_LOCAL_SOURCE" = "true" ] ; then
  # Downloading glibc source bundle file. The '-c' option allows the download to resume.
  echo "Downloading shadowsocks source bundle from $DOWNLOAD_URL"
  git clone $DOWNLOAD_URL
  cd shadowsocks-libev
  git submodule update --init
else
  echo "Using local shadowsocks source bundle $SRC_DIR/source/$ARCHIVE_FILE"
fi

# Delete folder with previously extracted glibc.
echo "Removing shadowsocks work area. This may take a while..."
cd $SRC_DIR
rm -rf work/shadowsocks-libev
ln -f -s ../source/shadowsocks-libev work/


# Extract glibc to folder 'work/glibc'.
# Full path will be something like 'work/glibc/glibc-2.23'.
cd $SRC_DIR

echo "*** GET SHADOWSOCKS END ***"

