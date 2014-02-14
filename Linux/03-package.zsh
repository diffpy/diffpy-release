#!/bin/zsh -f

setopt err_exit
setopt extendedglob

MYDIR="$(cd ${0:h} && pwd)"
cd $MYDIR

PACKAGE=diffpy-1.0-$CPUTYPE-$(date '+%Y%m%d')
mkdir -p $PACKAGE
cp -rlu bin include lib share src *.pth runtests.sh INSTALL.txt $PACKAGE/
cp -rlu buildtools update.zsh $PACKAGE/
cp -rlu 00-clean.zsh 01-fetchsources.zsh 02-buildall.zsh $PACKAGE/buildtools

# clean files
./00-clean.zsh $PACKAGE

cp /usr/lib/libboost_python-py27.so* $PACKAGE/lib
cp /usr/lib/libboost_serialization.so* $PACKAGE/lib

# finally create the tar bundle
tar czf ${PACKAGE}.tar.gz \
    --numeric-owner --owner=0 --group=0 $PACKAGE

# and remove the package directory itself
rm -rf $PACKAGE
