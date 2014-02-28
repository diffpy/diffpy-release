#!/bin/zsh -f

setopt err_exit
setopt extendedglob

MYDIR="$(cd ${0:h} && pwd)"
cd $MYDIR
PACKAGE=${1:-$MYDIR}

# clean up all git repositories
for gd in ${PACKAGE}/src/*/.git(:h); do
    if [[ $gd != *libobjcryst ]]; then
        (cd $gd && git clean -fdX)
    fi
done

# clean boost related
rm -vrf ${PACKAGE}/src/boost

# clean up pycifrw
rm -vrf ${PACKAGE}/src/pycifrw/pycifrw/build

# clean up build directories in all sans packages
rm -vrf ${PACKAGE}/src/sans/data_util/build
rm -vrf ${PACKAGE}/src/sans/pr_inversion/build
rm -vrf ${PACKAGE}/src/sans/sansdataloader/build
rm -vrf ${PACKAGE}/src/sans/sansmodels/build

# remove any pyc files
find ${PACKAGE} -type f -name '*.pyc' -print0 | xargs -0 -r rm -v

if [[ $PACKAGE == $MYDIR ]]; then
    # clean libobjcryst
    cd $PACKAGE/src/libobjcryst && ./makesdist --clean && cd $PACKAGE
    # clean the build files
    rm -vrf bin include lib share
    # check if any of the unwanted files are still around
    allfiles=( ${PACKAGE}/**/*~*.git*(.N) )
    undesired=(
        ${PACKAGE}/**/build(N/)
        ${PACKAGE}/**/*(-@N)
        ${(M)allfiles:#*.o}
        ${(M)allfiles:#*.py[oc]}
    )

    else
        # check if any of the unwanted files are still around
        allfiles=( ${PACKAGE}/**/*~*.git*(.N) )
        undesired=(
            ${PACKAGE}/**/build(N/)
            ${PACKAGE}/**/*(-@N)
            ${(M)allfiles:#*.o}
            ${(M)allfiles:#*.py[oc]}
        )
fi

if [[ -n ${undesired} ]]; then
    print -u2 "Some files were not cleaned up:"
    print -u2 -l ${undesired}
fi

