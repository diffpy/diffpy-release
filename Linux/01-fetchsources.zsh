#!/bin/zsh -f

setopt extendedglob
setopt err_exit

BASEDIR="${0:A:h}"
SRCDIR=${BASEDIR}/src

# git repositories for the sources in order of
# (project, URL, branch[:TagOrHash])
gitrepos=(
    diffpy.Structure
        https://github.com/diffpy/diffpy.Structure.git
        master:v1.2b2
    diffpy.utils
        https://github.com/diffpy/diffpy.utils.git
        master:v1.1b1
    pyobjcryst
        https://github.com/diffpy/pyobjcryst.git
        master:v1.0b4
    periodictable
        https://github.com/pkienzle/periodictable.git
        master:v1.4.1
    cxxtest
        https://github.com/CxxTest/cxxtest.git
        master:4.3
    libdiffpy
        https://github.com/diffpy/libdiffpy.git
        master:v1.2a0
    libobjcryst
        https://github.com/diffpy/libobjcryst.git
        master:v1.9.8b
    diffpy.srreal
        https://github.com/diffpy/diffpy.srreal.git
        master:v1.0a0
    diffpy.srfit
        https://github.com/diffpy/diffpy.srfit.git
        master:v1.0b4
)

# Mercurial repositories for the sources in order of
# (project, URL, branch[:TagOrHash])
hgrepos=(
)

# URLs to source code bundles as (directory, URL)
tarballs=(
    pycifrw
        https://bitbucket.org/jamesrhester/pycifrw/downloads/PyCifRW-3.6.1.tar.gz
)

# Subversion repositories as (targetpath, URL)
svnrepos=(
    sans/data_util
        svn://svn@danse.us/common/releases/util-1.0.0@1501
    sans/sansdataloader
        svn://svn@danse.us/sans/releases/sansdataloader-1.0.0@5489
    sans/sansmodels
        svn://svn@danse.us/sans/releases/sansmodels-1.0.0@5489
    sans/pr_inversion
        svn://svn@danse.us/sans/releases/pr_inversion-1.0.0@5489
)


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


fetchhgrepository() {
    [[ $# == 3 ]] || exit $?
    local tgtdir=$1 url=$2 branch=${3%%:*}
    local tag=${${3#${branch}}##*:}
    if [[ ! -d $tgtdir ]]; then
        hg clone -b $branch $url $tgtdir
    else
        ( cd $tgtdir && hg pull -u -b $branch )
    fi
    if [[ -n $tag ]]; then
        ( cd $tgtdir && hg update $tag )
    fi
}


fetchsvnrepository() {
    [[ $# == 2 ]] || exit $?
    local tgtdir=$1 url=$2
    svn checkout $url $tgtdir
}


fetchtarball() {
    [[ $# == 2 ]] || exit $?
    local tgtdir=$1 url=$2
    local wget_opts
    wget_opts=( --timestamping --no-verbose )
    if [[ -d /opt/local/share/curl ]]; then
        wget_opts+=( --ca-directory=/opt/local/share/curl )
    fi
    mkdir -p $tgtdir
    ( cd $tgtdir && wget $wget_opts $url )
}


# Download all required sources
mkdir -p $SRCDIR
cd $SRCDIR
for t u b in $gitrepos;  fetchgitrepository $t $u $b
for t u b in $hgrepos;  fetchhgrepository $t $u $b
for t u in $svnrepos;  fetchsvnrepository $t $u
for t u in $tarballs;  fetchtarball $t $u

# Finally copy addons to the SRCDIR.
rsync -av ${BASEDIR}/src-addons/ ${SRCDIR}/
