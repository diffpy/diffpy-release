#!/bin/zsh -f

DOC="\
Update and compile the diffpy pojects

System packages required for source build

    apt-get install \
        git libboost-all-dev libgsl0-dev mercurial python-dev \
        python-numpy python-setuptools scons wget zsh
"

MAXUNICODE=$(python -c 'import sys;print sys.maxunicode')
tgtdir=src/boost
boostdir=$tgtdir/boost_1_55_0
url=http://sourceforge.net/projects/boost/files/boost/1.55.0/boost_1_55_0.tar.bz2

fetchboost() {
    if [[ -f ${tgtdir}/${url:t} ]]; then
        return
    fi
    mkdir -p $tgtdir
    ( cd $tgtdir && wget -N $url && tar jxf ${url:t} )
}

buildboost() {
    (cd $boostdir && ./bootstrap.sh --with-libraries=python,serialization)
    (cd $boostdir && ./b2)
}

# build boost if python is not system python
if [[ $MAXUNICODE != 1114111 ]]; then
    fetchboost
    buildboost
    PYTHONBIN=$(which python)
    export LIBRARY_PATH=$PWD/$boostdir/stage/lib:${PYTHONBIN:h}/../lib:$LIBRARY_PATH
    export LD_LIBRARY_PATH=$PWD/$boostdir/stage/lib:${PYTHONBIN:h}/../lib:$LD_LIBRARY_PATH
    export CPATH=$PWD/$boostdir:${PYTHONBIN:h}/../include:$CPATH
fi

# build diffpy project
if [[ ! -f 00-clean.zsh || ! -f 01-fetchsources.zsh || ! -f 02-buildall.zsh ]]; then
    cp -f ./src-addons/*.zsh .
fi

./00-clean.zsh
./01-fetchsources.zsh
./02-buildall.zsh

if [[ $MAXUNICODE != 1114111 ]]; then
    cp -f $boostdir/stage/lib/* $PWD/lib
fi
