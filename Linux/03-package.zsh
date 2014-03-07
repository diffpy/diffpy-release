#!/bin/zsh -f
# Usage:
#   ./03-package.zsh       # for binary distribution
#   ./03-package.zsh src   # for source-only distribution

setopt err_exit
setopt extendedglob

umask 022

MYDIR=${0:A:h}
cd $MYDIR

# Use gnutar on Mac OS X
TAR=tar
if [[ $OSTYPE == darwin* ]]; then
    TAR=gnutar
fi

# Support [src|source] argument for source-only package
if [[ $1 != (src|source) ]]; then
    WITH_BINARIES=1
fi

PKGNAME=diffpy_cmi
VERSION=${${"$(git describe --match='v[[:digit:]]*')"%-g[[:xdigit:]]##}#v}

if [[ -n $WITH_BINARIES ]]; then
    pyversion=( lib/python2*(/om[1]:t) )
    pyversion=${pyversion/thon/}
    SUFFIX=-${pyversion}-${(L)$(uname -s)}-${CPUTYPE}
fi

PACKAGE=dist/${PKGNAME}-${VERSION}${SUFFIX}
mkdir -p $PACKAGE
mkdir -p ${PACKAGE}/lib

# First copy only source distribution files
excludes=(
    build dist temp '.sconsign.*' .sconf_temp '*.pyc'
    # remove subversion files in the packaged tree
    .svn
)

rsync -av --delete --link-dest=$PWD \
    --exclude=$PACKAGE --exclude=${^excludes} \
    bin include share src *.pth *.sh *.txt \
    ${WITH_BINARIES+lib} \
    $PACKAGE/

# finally create the tar bundle
$TAR czf ${PACKAGE}.tar.gz \
    --directory ${PACKAGE:h} \
    --numeric-owner --owner=0 --group=0 ${PACKAGE:t}

# and remove the package directory itself
rm -rf $PACKAGE
