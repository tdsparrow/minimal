#!/bin/sh

echo "*** BUILD SHADOWSOCKS BEGIN ***"

SRC_DIR=$(pwd)

# Read the 'JOB_FACTOR' property from '.config'
JOB_FACTOR="$(grep -i ^JOB_FACTOR .config | cut -f2 -d'=')"

# Read the 'CFLAGS' property from '.config'
CFLAGS="$(grep -i ^CFLAGS .config | cut -f2 -d'=')"

# Find the number of available CPU cores.
NUM_CORES=$(grep ^processor /proc/cpuinfo | wc -l)

# Calculate the number of 'make' jobs to be used later.
NUM_JOBS=$((NUM_CORES * JOB_FACTOR))

# Save the kernel installation directory.
KERNEL_INSTALLED=$SRC_DIR/work/kernel/kernel_installed

cd work/shadowsocks-libev 
SS_SRC=$(pwd)
SS_INSTALLED=$(pwd)/ss_installed

# create build dir
cd build

# glibc is configured to use the root folder (--prefix=) and as result all
# libraries will be installed in '/lib'. Note that on 64-bit machines BusyBox
# will be linked with the libraries in '/lib' while the Linux loader is expected
# to be in '/lib64'. Kernel headers are taken from our already prepared kernel
# header area (see xx_build_kernel.sh). Packages 'gd' and 'selinux' are disabled
# for better build compatibility with the host system.
echo "Configuring ss..."
cmake -D WITH_STATIC=OFF .. 

# Compile glibc with optimization for "parallel jobs" = "number of processors".
echo "Building ss..."
make -j $NUM_JOBS

# Install glibc in the installation area, e.g. 'work/glibc/glibc_installed'.
echo "Installing badvpn..."
make install \
  DESTDIR=$SS_INSTALLED \
  -j $NUM_JOBS

cd $SRC_DIR

echo "*** BUILD SHADOWSOCKS END ***"

