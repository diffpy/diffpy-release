#!/bin/zsh -f

setopt err_exit
setopt extendedglob

MYDIR="$(cd ${0:h} && pwd)"
cd $MYDIR
PACKAGE=${1:-$MYDIR}

# clean up all git repositories
for gd in ${PACKAGE}/src/*/.git(:h); do
    (cd $gd && git clean -fdX)
done

# clean up pycifrw
rm -vrf ${PACKAGE}/src/pycifrw/pycifrw/build

# clean up build directories in all sans packages
rm -vrf ${PACKAGE}/src/sans/data_util/build
rm -vrf ${PACKAGE}/src/sans/pr_inversion/build
rm -vrf ${PACKAGE}/src/sans/sansdataloader/build
rm -vrf ${PACKAGE}/src/sans/sansmodels/build

# remove any pyc files
find ${PACKAGE} -type f -name '*.pyc' -print0 | xargs -0 -r rm -v


# clean up intermediate object files in cctbx_build
CCTBXBUILD=$PACKAGE/src/cctbx/cctbx_build
CCTBXSOURCES=$PACKAGE/src/cctbx/cctbx_sources

if [[ $PACKAGE == $MYDIR ]]; then
    # clean the build files
    rm -vrf bin include lib share $CCTBXSOURCES $CCTBXBUILD
    cd $PACKAGE/src/cctbx && tar xzf cctbx_bundle.tar.gz
    # check if any of the unwanted files are still around
    allfiles=( ${PACKAGE}/**/*~*.git*(.N) )
    undesired=(
        ${PACKAGE}/**/build(N/)
        ${PACKAGE}/**/*(-@N)
        ${(M)allfiles:#*.o}
        ${(M)allfiles:#*.py[oc]}
    )

    else
        # clean the boost and examples of cctbx
        ${CCTBXBUILD}/bin/libtbx.scons -c -C $CCTBXBUILD
        rm -vrf ${CCTBXSOURCES}/boost
        rm -vrf ${CCTBXSOURCES}/phenix_examples

        # clean up tar bundles from 01-fetchsources.zsh
        rm -vf $PACKAGE/src/cctbx/cctbx_bundle.tar.gz
        rm -vf $PACKAGE/src/cctbx/cctbx_install_script.csh
        rm -vf $PACKAGE/src/pyobjcryst/libobjcryst/newmat/newmat11.tar.gz
        # check if any of the unwanted files are still around
        allfiles=( ${PACKAGE}/**/*~*.git*(.N) )
        undesired=(
            ${PACKAGE}/**/build(N/)
            ${PACKAGE}/**/*(-@N)
            ${(M)allfiles:#*.o}
            ${(M)allfiles:#*.py[oc]}
            ${(M)allfiles:#*/cctbx_bundle.tar.gz}
            ${(M)allfiles:#*/cctbx_install_script.csh}
            ${(M)allfiles:#*/newmat11.tar.gz}
        )
fi

if [[ -n ${undesired} ]]; then
    print -u2 "Some files were not cleaned up:"
    print -u2 -l ${undesired}
fi

