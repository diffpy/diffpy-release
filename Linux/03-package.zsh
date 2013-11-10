#!/bin/zsh -f

setopt err_exit
setopt extendedglob

MYDIR="$(cd ${0:h} && pwd)"
cd $MYDIR

PACKAGE=diffpy-1.0-$CPUTYPE-$(date '+%Y%m%d')
mkdir -p $PACKAGE
cp -rlu bin include lib share src *.pth runtests.sh INSTALL.txt $PACKAGE/

# clean files
./00-clean.zsh $PACKAGE

# finally create the tar bundle
tar czf ${PACKAGE}.tar.gz \
    --numeric-owner --owner=0 --group=0 $PACKAGE

# and remove the package directory itself
rm -rf $PACKAGE
