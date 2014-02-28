#!/bin/zsh -f

setopt extendedglob
setopt err_exit

MYDIR="$(cd ${0:h} && pwd)"
SRCDIR=${MYDIR}/src

# git repositories for the sources in order of
# (project, URL, branch[:TagOrHash])
gitrepos=(
    diffpy.Structure
        https://github.com/diffpy/diffpy.Structure.git
        master
    diffpy.utils
        https://github.com/diffpy/diffpy.utils.git
        master
    pyobjcryst
        https://github.com/diffpy/pyobjcryst.git
        master
    periodictable
        https://github.com/pkienzle/periodictable.git
        master
    cxxtest
        https://github.com/CxxTest/cxxtest.git
        master
    libdiffpy
        https://github.com/diffpy/libdiffpy.git
        develop
    libobjcryst
        https://github.com/diffpy/libobjcryst.git
        master
    diffpy.srreal
        https://github.com/diffpy/diffpy.srreal.git
        develop
    diffpy.srfit
        https://github.com/diffpy/diffpy.srfit.git
        master
)

# Mercurial repositories for the sources in order of
# (project, URL, branch[:TagOrHash])
hgrepos=(
    pycifrw
        https://pavoljuhas@bitbucket.org/pavoljuhas/pycifrw
        stable
)

# URLs to source code bundles as (directory, URL)
tarballs=(
    #cctbx
    #    http://cci.lbl.gov/cctbx_build/results/2013_07_05_0005/cctbx_bundle.tar.gz
    #pyobjcryst/libobjcryst/newmat
    #    http://www.robertnz.net/ftp/newmat11.tar.gz
)

# Subversion repositories as (targetpath, URL)
svnrepos=(
    #pyobjcryst/libobjcryst/ObjCryst
    #    https://svn.code.sf.net/p/objcryst/code/trunk/ObjCryst
    sans/data_util
        svn://svn@danse.us/common/util
    sans/sansdataloader
        svn://svn@danse.us/sans/trunk/sansdataloader
    sans/sansmodels
        svn://svn@danse.us/sans/trunk/sansmodels
    sans/pr_inversion
        svn://svn@danse.us/sans/trunk/pr_inversion
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
    if [[ -n $tag ]]; then
        cd $tgtdir && git checkout $tag
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
    if [[ -f ${tgtdir}/${url:t} ]]; then
        return
    fi
    mkdir -p $tgtdir
    ( cd $tgtdir && wget -N $url && tar xzf ${url:t} )
}


# Download all required sources
cd $SRCDIR
for t u b in $gitrepos;  fetchgitrepository $t $u $b
for t u b in $hgrepos;  fetchhgrepository $t $u $b
for t u in $svnrepos;  fetchsvnrepository $t $u
for t u in $tarballs;  fetchtarball $t $u

cd $SRCDIR/libobjcryst && ./makesdist --clean && ./makesdist 1-3
