#!/bin/zsh -f

umask 022
DOC="\
${0:t} update and compile the diffpy pojects
usage: ${0:t} [options]

With no arguments, latest version will be checked out from github
and compiled. If you only would like to recompile the source code
included in bundle, use --compile(or -c) to disable the fetching
process.

Options:

    --compile(-c)    compile source code without fetching
    --help(-h)       display this message and exit

Note:

System packages required for source build

    apt-get install \
        git libboost-all-dev libgsl0-dev mercurial python-dev \
        python-numpy python-setuptools scons wget zsh

If the boost_python installed is not compatible with the python
version installed, this script will try to download and build 
boost_python. 
"
DOC=${${DOC##[[:space:]]##}%%[[:space:]]##}

zmodload zsh/zutil
zparseopts -K -E -D \
    h=opt_help -help=opt_help c=opt_compile -compile=opt_compile

if [[ -n ${opt_help} ]]; then
    print -r -- $DOC
    exit
fi

MAXUNICODE=$(python -c 'import sys;print sys.maxunicode')
boostdir=src/boost/boost_1_55_0

fetchgitrepository() {
    [[ $# == 3 ]] || exit $?
    local tgtdir=$1 url=$2 branch=${3%%:*}
    local tag=${${3#${branch}}##*:}
    if [[ ! -d $tgtdir ]]; then
        git clone -b $branch $url $tgtdir
    else (
        cd $tgtdir &&
        git checkout $branch &&
        git pull --tags origin $branch
        )
    fi
    if [[ -n $tag ]]; then (
        cd $tgtdir
        if [[ -z "$(git log -1 $branch..$tag)" ]]; then
            git reset --hard $tag
        else
            git checkout --quiet $tag
        fi
        )
    fi
}

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
}

recompile() {
    # build diffpy project
    if [[ ! -f 00-clean.zsh || ! -f 01-fetchsources.zsh || ! -f 02-buildall.zsh ]]; then
        cp -f ./buildtools/00-clean.zsh ./buildtools/02-buildall.zsh .
    fi

    ./00-clean.zsh
    ./02-buildall.zsh

    # rm -rf 00-clean.zsh 02-buildall.zsh
}

update() {
    # checkout the latest version and compile
    mkdir -p buildtools
    cd buildtools
    fetchgitrepository diffpy-release https://github.com/diffpy/diffpy-release.git master
    cd diffpy-release/Linux
    cp -rf 00-clean.zsh 01-fetchsources.zsh 02-buildall.zsh src-addons ../../..
    cd ../../..

    ./00-clean.zsh
    ./01-fetchsources.zsh
    ./02-buildall.zsh

    # rm -rf 00-clean.zsh 01-fetchsources.zsh 02-buildall.zsh src-addons
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

if [[ -n ${opt_compile} ]]; then
    recompile
else
    update
fi

if [[ $MAXUNICODE != 1114111 ]]; then
    cp -f $boostdir/stage/lib/* $PWD/lib
fi