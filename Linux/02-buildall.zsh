#!/bin/zsh -f

setopt extendedglob
setopt err_exit
umask 022

DOC="\
${0:t} build all codes for the diffpy Linux bundle.
usage: ${0:t} [options] [FIRST] [LAST]

With no arguments all packages are built in sequence.  Otherwise the build
starts at package number FIRST and terminates after package LAST.
Use option --list for displaying package numbers.

Options:

  --list        show a numbered list of packages and exit
  -h, --help    display this message and exit

Environment variables can be used to override script defaults:

  PREFIX        base directory for installing the binaries [.]
  PYTHON        python executable used for the build [python]
  EASY_INSTALL  easy_install program used for the build [easy_install]
  SCONS         SCons program used for the build [scons]
  NCPU          number of CPUs used in parallel builds [all-cores].
"
DOC=${${DOC##[[:space:]]##}%%[[:space:]]##}
MYDIR=${0:A:h}

# Parse Options --------------------------------------------------------------

zmodload zsh/zutil
zparseopts -K -E -D \
    h=opt_help -help=opt_help l=opt_list -list=opt_list

if [[ -n ${opt_help} ]]; then
    print -r -- $DOC
    exit
fi

integer FIRST=${1:-"1"}
integer LAST=${2:-"9999"}

# Resolve parameters that can be overloaded from the environment -------------

: ${PREFIX:=${MYDIR}}
: ${PYTHON:==python}
: ${EASY_INSTALL:==easy_install}
: ${SCONS:==scons}
: ${NCPU:=$(${PYTHON} -c \
    'from multiprocessing import cpu_count; print cpu_count()')}

# Determine other parameters -------------------------------------------------

SRCDIR=${MYDIR}/src
BINDIR=${PREFIX}/bin
INCLUDEDIR=${PREFIX}/include
LIBDIR=${PREFIX}/lib
PYTHON_VERSION=$($PYTHON -c 'import sys; print "%s.%s" % sys.version_info[:2]')
PYTHONDIR=$LIBDIR/python${PYTHON_VERSION}/site-packages
RELPATH=${MYDIR}/buildtools/relpath

# Adjust environment variables used in the build -----------------------------

export PATH=$BINDIR:$PATH
export LIBRARY_PATH=$LIBDIR:$LIBRARY_PATH
export LD_LIBRARY_PATH=$LIBDIR:$LD_LIBRARY_PATH
export CPATH=$INCLUDEDIR:$CPATH
export PYTHONPATH=$PYTHONDIR:$PYTHONPATH

# Define function for building or skipping the packages ----------------------

integer BIDX=0

ListSkipOrBuild() {
    local name=${1?}
    (( ++BIDX ))
    if [[ -n ${opt_list} ]]; then
        print $BIDX $name
        return 0
    fi
    if [[ $BIDX -lt $FIRST || $BIDX -gt $LAST ]]; then
        return 0
    fi
    local dashline="# $BIDX $name ${(l:80::-:):-}"
    print ${dashline[1,78]}
    # return false status to trigger the build section
    return 1
}

# Build commands here --------------------------------------------------------

if [[ -n ${opt_list} ]]; then
    mkdir -p $BINDIR $INCLUDEDIR $LIBDIR $PYTHONDIR
fi

cd $SRCDIR

ListSkipOrBuild pycifrw || {
    easy_install -UZN --prefix=$PREFIX PyCifRW
}

ListSkipOrBuild diffpy.Structure || {
    easy_install -UZN --prefix=$PREFIX ${SRCDIR}/diffpy.Structure
}

ListSkipOrBuild diffpy.utils || {
    easy_install -UZN --prefix=$PREFIX ${SRCDIR}/diffpy.utils
}

ListSkipOrBuild periodictable || {
    easy_install -UZN --prefix=$PREFIX ${SRCDIR}/periodictable
}

ListSkipOrBuild cctbx || {
    mkdir -p ${SRCDIR}/cctbx/cctbx_build
    cctbx_configargs=(
        --no-bin-python
        mmtbx libtbx cctbx iotbx fftw3tbx rstbx spotfinder
        smtbx mmtbx cbflib clipper
    )
    cd ${SRCDIR}/cctbx/cctbx_build
    $PYTHON ../cctbx_sources/libtbx/configure.py $cctbx_configargs
    ./bin/libtbx.scons -j $NCPU no_boost_python=yes
    ( source setpaths.sh &&
      cd ../cctbx_sources/setup &&
      ./unix_integrate_cctbx.sh --yes --prefix=$PREFIX all
    )
}

ListSkipOrBuild cxxtest || {
    cd $BINDIR && ln -sf ../src/cxxtest/bin/cxxtestgen && ls -L cxxtestgen
}

ListSkipOrBuild libObjCryst || {
    cd $SRCDIR/pyobjcryst/libobjcryst
    scons -j $NCPU build=fast with_shared_cctbx=yes prefix=$PREFIX install
}

ListSkipOrBuild pyobjcrst || {
    cd $SRCDIR/pyobjcryst
    scons -j $NCPU build=fast prefix=$PREFIX install
}

ListSkipOrBuild libdiffpy || {
    cd $SRCDIR/libdiffpy
    scons -j $NCPU build=fast enable_objcryst=yes test
    scons -j $NCPU build=fast enable_objcryst=yes prefix=$PREFIX install 
}

ListSkipOrBuild diffpy.srreal || {
    cd $SRCDIR/diffpy.srreal
    scons -j $NCPU build=fast prefix=$PREFIX install
}

ListSkipOrBuild sans/data_util || {
    easy_install -UZN --prefix=$PREFIX ${SRCDIR}/sans/data_util
}

ListSkipOrBuild sans/sansdataloader || {
    easy_install -UZN --prefix=$PREFIX ${SRCDIR}/sans/sansdataloader
}

ListSkipOrBuild sans/sansmodels || {
    easy_install -UZN --prefix=$PREFIX ${SRCDIR}/sans/sansmodels
}

ListSkipOrBuild sans/pr_inversion || {
    easy_install -UZN --prefix=$PREFIX ${SRCDIR}/sans/pr_inversion
}

ListSkipOrBuild diffpy.srfit || {
    easy_install -UZN --prefix=$PREFIX ${SRCDIR}/diffpy.srfit
}

ListSkipOrBuild patch_so_rpath || {
    libsofiles=( $LIBDIR/*.so(*) )
    pyextfiles=(
        ${SRCDIR}/cctbx/cctbx_build/lib/*_ext.so(*)
        ${LIBDIR}/python*/site-packages/**/*.so(*)
    )
    typeset -aU depdirs
    for f in $libsofiles $pyextfiles; do
        sodeps=( $(ldd $f | grep ${(F)libsofiles} | awk '$2 == "=>" {print $3}') )
        [[ ${#sodeps} != 0 ]] || continue
        depdirs=( $($RELPATH ${sodeps:h} ${f:h} ) )
        depdirs=( ${${(M)depdirs:#.}/*/'$ORIGIN'} '$ORIGIN'/${^${depdirs:#.}} )
        print "patchelf --set-rpath ${(j,:,)depdirs} $f"
        patchelf --set-rpath ${(j,:,)depdirs} $f
    done
}
