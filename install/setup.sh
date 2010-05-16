#! /bin/sh

ECHO=`which echo`
BASE=`pwd`
PREFIX="/opt/hax"
PARALLEL=5

DIR_BASE=`pwd`
DIR_LOGS="$BASE/logs"
DIR_CHECKSUM="$BASE/checksums"
DIR_DOWNLOAD="$BASE/downloads"
DIR_BUILDING="$BASE/build"

NAME_SDCC="sdcc-extra-src-20100516-5824"
NAME_BINUTILS="binutils-2.20.1"
NAME_GCC="gcc-4.4.3"
NAME_NEWLIB="newlib-1.18.0"

URL_SDCC="http://sdcc.sourceforge.net/snapshots/sdcc-extra-src/$NAME_SDCC.tar.bz2"
URL_BINUTILS="ftp://ftp.gnu.org/gnu/binutils/$NAME_BINUTILS.tar.gz"
URL_GCC="ftp://ftp.gnu.org/gnu/gcc/$NAME_GCC/$NAME_GCC.tar.gz"
URL_NEWLIB="ftp://sources.redhat.com/pub/newlib/$NAME_NEWLIB.tar.gz"

MD5_SDCC="8db303a896d6d046fb5cb108fcc025dc  $NAME_SDCC.tar.bz2"
MD5_BINUTILS="eccf0f9bc62864b29329e3302c88a228  $NAME_BINUTILS.tar.gz"
MD5_GCC="9d58930376e4685c7682aa3e0f0a442b  $NAME_GCC.tar.gz"
MD5_NEWLIB="3dae127d4aa659d72f8ea8c0ff2a7a20  $NAME_NEWLIB.tar.gz"

source "helper.sh"

# Build the necessary directory structure.
mkdir_safe $DIR_LOGS
mkdir_safe $DIR_CHECKSUM
mkdir_safe $DIR_DOWNLOAD
mkdir_safe $DIR_BUILDING

# Populate the checksums directory.
$ECHO "$MD5_SDCC"     > "$DIR_CHECKSUM/$NAME_SDCC.md5"
$ECHO "$MD5_BINUTILS" > "$DIR_CHECKSUM/$NAME_BINUTILS.md5"
$ECHO "$MD5_GCC"      > "$DIR_CHECKSUM/$NAME_GCC.md5"
$ECHO "$MD5_NEWLIB"   > "$DIR_CHECKSUM/$NAME_NEWLIB.md5"

##
## PIC TOOLCHAIN
##

# SDCC
#
cd "$DIR_BASE"

header "PIC" "SDCC" "Downloading"
download "$URL_SDCC" "$NAME_SDCC" "tar.bz2"
wipe

header "PIC" "SDCC" "Extracting"
extract "$DIR_DOWNLOAD/$NAME_SDCC.tar.bz2" "$DIR_BUILDING"

header "PIC" "SDCC" "Configuring"
mkdir_safe "$DIR_BUILDING/sdcc-extra/build"
cd "$DIR_BUILDING/sdcc-extra/build"
../configure --prefix="$PREFIX" 2>&1 > "$DIR_LOGS/${NAME_SDCC}_configure.log"
if_error $? "unable to configure SDCC"

header "PIC" "SDCC" "Compiling"
make -j$PARALLEL 2>&1 > "$DIR_LOGS/${NAME_SDCC}_compile.log"
if_error $? "unable to build SDCC"

header "PIC" "SDCC" "Installing"
sudo make install  2>&1 > "$DIR_LOGS/${NAME_SDCC}_install.log"
if_error $? "unable to install SDCC"

header "PIC" "SDCC" "Verifying Installation"
"$PREFIX/bin/sdcc" -v | grep "SDCC" > /dev/null
if_error $@ "\"sdcc\" failed verification"

header "PIC" "SDCC" "Cleaning Up"
rm -rf "$DIR_DOWNLOAD/$NAME_SDCC.tar.bz2" \
       "$DIR_BUILDING/sdcc-extra"

##
## ARM TOOLCHAIN
##

# Binutils
#
cd "$DIR_BASE"

header "ARM" "Binutils" "Downloading"
download "$URL_BINUTILS" "$NAME_BINUTILS" "tar.gz"
wipe

header "ARM" "Binutils" "Extracting"
extract "$DIR_DOWNLOAD/$NAME_BINUTILS.tar.gz" "$DIR_BUILDING"

header "ARM" "Binutils" "Configuring"
mkdir_safe "$DIR_BUILDING/$NAME_BINUTILS/build"
cd "$DIR_BUILDING/$NAME_BINUTILS/build"
../configure --prefix="$PREFIX" --target=arm-none-eabi --disable-werror 2>&1 > "$DIR_LOGS/${NAME_BINUTILS}_configure.log"
if_error $? "unable to configure Binutils"

header "ARM" "Binutils" "Compiling"
make -j$PARALLEL 2>&1 > "$DIR_LOGS/${NAME_BINUTILS}_compile.log"
if_error $? "unable to build Binutils"

header "ARM" "Binutils" "Installing"
sudo make install 2>&1 > "$DIR_LOGS/${NAME_BINUTILS}_install.log"

if_error $? "unable to install Binutils"

# GCC
#
cd "$DIR_BASE"

header "ARM" "GCC" "Downloading"
download "$URL_GCC" "$NAME_GCC" "tar.gz"
wipe

header "ARM" "GCC" "Extracting"
extract "$DIR_DOWNLOAD/$NAME_GCC.tar.gz" "$DIR_BUILDING"

header "ARM" "GCC" "Configuring"
mkdir_safe "$DIR_BUILDING/$NAME_GCC/build"
cd "$DIR_BUILDING/$NAME_GCC/build"
../configure --prefix="$PREFIX" --target=arm-none-eabi --without-header --with-newlib  --with-gnu-as --with-gnu-ld --enable-languages=c --disable-werror 2>&1 > "$DIR_LOGS/${NAME_GCC}_configure.log"
if_error $? "unable to configure GCC"

header "ARM" "GCC" "Compiling"
umake -j$PARALLEL all-gcc 2>&1 > "$DIR_LOGS/${NAME_GCC}_compile.log"
if_error $? "unable to build GCC"

header "ARM" "GCC" "Installing"
sudo make install-gcc 2>&1 > "$DIR_LOGS/${NAME_GCC}_install.log"
if_error $? "unable to install GCC"

# Newlib
#
cd "$DIR_BASE"

header "ARM" "Newlib" "Downloading"
download "$URL_NEWLIB" "$NAME_NEWLIB" "tar.gz"
wipe

header "ARM" "Newlib" "Extracting"
extract "$DIR_DOWNLOAD/$NAME_NEWLIB.tar.gz" "$DIR_BUILDING"

header "ARM" "Newlib" "Configuring"
mkdir_safe "$DIR_BUILDING/$NAME_NEWLIB/build"
cd "$DIR_BUILDING/$NAME_NEWLIB/build"
../configure --prefix="$PREFIX" --target=arm-none-eabi --disable-werror 2>&1 > "$DIR_LOGS/${NAME_NEWLIB}_configure.log"
if_error $? "unable to configure Newlib"

header "ARM" "Newlib" "Compiling"
make -j$PARALLEL 2>&1 > "$DIR_LOGS/${NAME_NEWLIB}_compile.log"
if_error $? "unable to build Newlib"

header "ARM" "Newlib" "Installing"
sudo make install 2>&1 > "$DIR_LOGS/${NAME_NEWLIB}_install.log"
if_error $? "unable to install Newlib"

# GCC (Bootstrap)
#
cd "$DIR_BASE"

header "ARM" "GCC (Bootstrap)" "Configuring"
mkdir_safe "$DIR_BUILDING/$NAME_GCC/build"
cd "$DIR_BUILDING/$NAME_GCC/build"
../configure --prefix="$PREFIX" --target=arm-none-eabi --with-newlib --with-gnu-as --with-gnu-ld --disable-shared --disable-libssp --enable-languages=c --disable-werror 2>&1 > "$DIR_LOGS/${NAME_GCC}_bs_configure.log"
if_error $? "unable to boostrap GCC"

header "ARM" "GCC (Bootstrap)" "Compiling"
make -j$PARALLEL 2>&1 > "$DIR_LOGS/${NAME_GCC}_bs_compile.log"
if_error $? "unable to bootstrap GCC"

header "ARM" "GCC (Bootstrap)" "Installing"
sudo make install 2>&1 > "$DIR_LOGS/${NAME_GCC}_bs_install.log"
if_error $? "unable to install bootstrapped GCC"

# Test GCC's Installation
#
header "ARM" "Verifying Installation"
"$PREFIX/bin/arm-none-eabi-gcc" -v 2>&1 | grep "^Target: arm-none-eabi$" > /dev/null
if_error $? "\"arm-none-eabi-gcc\" failed verification"

# Update the PATH environmental variable
#
header "ARM" "Updating PATH"

echo "$PATH" | grep "$PREFIX/bin" > /dev/null
if [ $? ]; then
	echo "export PATH=\"\$PATH:$PREFIX/bin\"" >> ~/.bashrc
	source ~/.bashrc
fi

echo "$PATH" | grep "$PREFIX/bin" > /dev/null
if_error $? "manually add \'$PREFIX/bin\' to your PATH to continue"

# Remove temporary files
#
header "ARM" "Cleaning Up"
rm -rf "$DIR_DOWNLOAD/$NAME_BINUTILS.tar.gz" \
       "$DIR_DOWNLOAD/$NAME_GCC.tar.gz"      \
       "$DIR_DOWNLOAD/$NAME_NEWLIB.tar.gz"   \
       "$DIR_BUILDING/$NAME_BINUTILS"        \
       "$DIR_BUILDING/$NAME_GCC"             \
       "$DIR_BUILDING/$NAME_NEWLIB"

header "ARM" "DONE"
