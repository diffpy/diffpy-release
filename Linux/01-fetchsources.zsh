#!/bin/zsh -f

setopt err_exit

MYDIR=${0:A:h}
SRCDIR=${MYDIR}/src

# git repositories for the sources in order of
# (project, URL, branch)
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
    diffpy.srreal   
        https://github.com/diffpy/diffpy.srreal.git
        develop
    diffpy.srfit    
        https://github.com/diffpy/diffpy.srfit.git
        master
)

# URLs to source code bundles as (directory, URL)
tarballs=(
    cctbx
        http://cci.lbl.gov/cctbx_build/results/2013_07_05_0005/cctbx_bundle.tar.gz
    pyobjcryst/libobjcryst/newmat
        http://www.robertnz.net/ftp/newmat11.tar.gz
)

# Subversion repositories as (targetpath, URL)
svnrepos=(
    pyobjcryst/libobjcryst/ObjCryst
        https://svn.code.sf.net/p/objcryst/code/trunk/ObjCryst
    sans/data_util
        svn://svn@danse.us/common/util
    sans/DataLoader
        svn://svn@danse.us/sans/trunk/DataLoader
    sans/sansmodels
        svn://svn@danse.us/sans/trunk/sansmodels
    sans/pr_inversion
        svn://svn@danse.us/sans/trunk/pr_inversion
)
        

fetchgitrepository() {
    [[ $# == 3 ]] || exit $?
    local tgtdir=$1 url=$2 branch=$3
    cd $SRCDIR
    if [[ ! -d $tgtdir ]]; then
        git clone -b $branch $url $tgtdir
    else
        cd $tgtdir && git pull origin $branch
    fi
}


fetchsvnrepository() {
    [[ $# == 2 ]] || exit $?
    local tgtdir=$1 url=$2
    cd $SRCDIR
    svn checkout $url $tgtdir
}


fetchtarball() {
    cd $SRCDIR
    [[ $# == 2 ]] || exit $?
    local tgtdir=$1 url=$2
    if [[ -f ${tgtdir}/${url:t} ]]; then
        return
    fi
    mkdir -p $tgtdir
    cd $tgtdir && curl -O $url
}

    
# Download all required sources
for t u b in $gitrepos;  fetchgitrepository $t $u $b
for t u in $svnrepos;  fetchsvnrepository $t $u
for t u in $tarballs;  fetchtarball $t $u

# extract tarballs

cctbxbundle=${SRCDIR}/cctbx/cctbx_bundle.tar.gz
tar xzf $cctbxbundle -C ${cctbxbundle:h}

newmatbundle=${SRCDIR}/pyobjcryst/libobjcryst/newmat/newmat11.tar.gz
tar xzf $newmatbundle -C ${newmatbundle:h}
