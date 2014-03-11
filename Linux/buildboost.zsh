#!/bin/zsh -f

MAXUNICODE=$(python -c 'import sys;print sys.maxunicode')
boostdir=src/boost/boost_1_55_0

fetchboost() {
    local tgtdir=src/boost
    local url=http://sourceforge.net/projects/boost/files/boost/1.55.0/boost_1_55_0.tar.bz2
    if [[ -f ${tgtdir}/${url:t} ]]; then
        return
    fi
    mkdir -p $tgtdir
    ( cd $tgtdir && wget -N $url && tar jxf ${url:t} )
}

buildboost() {
    (cd $boostdir && ./bootstrap.sh --with-libraries=python,serialization)
    (cd $boostdir && ./b2)
    mkdir -p lib include
    cp -rlu $boostdir/stage/lib/* lib
    cp -rlu $boostdir/boost include
}

if [[ $MAXUNICODE != 1114111 ]]; then
    fetchboost
    buildboost
fi
