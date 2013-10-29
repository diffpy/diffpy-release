#!/bin/zsh -f

setopt err_exit
MYDIR=${0:A:h}

# These parameters can be overloaded from the environment
: ${PREFIX:=${MYDIR}}
: ${PYTHON:==python}
: ${NCPU:=4}

SRCDIR=${MYDIR}/src
BINDIR=${PREFIX}/bin
INCLUDEDIR=${PREFIX}/include
LIBDIR=${PREFIX}/lib
PYTHON_VERSION=$(
    ${PYTHON} -c 'import sys; print "%s.%s" % sys.version_info[:2]')
PYTHONDIR=$LIBDIR/python${PYTHON_VERSION}/site-packages

mkdir -p $BINDIR $INCLUDEDIR $LIBDIR $PYTHONDIR

# adjust environment variables
export PATH=$BINDIR:$PATH
export LIBRARY_PATH=$LIBDIR:$LIBRARY_PATH
export LD_LIBRARY_PATH=$LIBDIR:$LD_LIBRARY_PATH
export CPATH=$INCLUDEDIR:$CPATH
export PYTHONPATH=$PYTHONDIR:$PYTHONPATH

# build all packages in correct order
cd $SRCDIR

print "\
# pycifrw --------------------------------------------------------------------"
easy_install -UZN --prefix=$PREFIX PyCifRW

print "\
# diffpy.Structure -----------------------------------------------------------"
easy_install -UZN --prefix=$PREFIX ${SRCDIR}/diffpy.Structure

print "\
# diffpy.utils ---------------------------------------------------------------"
easy_install -UZN --prefix=$PREFIX ${SRCDIR}/diffpy.utils

print "\
# periodictable --------------------------------------------------------------"
easy_install -UZN --prefix=$PREFIX ${SRCDIR}/periodictable

print "\
# cctbx ----------------------------------------------------------------------"
mkdir -p ${SRCDIR}/cctbx/cctbx_build
cctbx_configargs=(
    --build-boost-python-extensions=False
    --no-bin-python
    mmtbx libtbx cctbx iotbx fftw3tbx rstbx spotfinder
    smtbx mmtbx cbflib clipper
)
cd ${SRCDIR}/cctbx/cctbx_build
$PYTHON ../cctbx_sources/libtbx/configure.py $cctbx_configargs
make
( source setpaths.sh &&
  cd ../cctbx_sources/setup &&
  ./unix_integrate_cctbx.sh --yes --prefix=$PREFIX all )

print "\
# cxxtest --------------------------------------------------------------------"
cd $BINDIR && ln -sf ../src/cxxtest/bin/cxxtestgen && ls -L cxxtestgen

print "\
# libObjCryst ----------------------------------------------------------------"
cd $SRCDIR/pyobjcryst/libobjcryst
scons -j $NCPU build=fast with_shared_cctbx=yes prefix=$PREFIX install

print "\
# pyobjcrst ------------------------------------------------------------------"
cd $SRCDIR/pyobjcryst
scons -j $NCPU build=fast prefix=$PREFIX install

print "\
# libdiffpy ------------------------------------------------------------------"
cd $SRCDIR/libdiffpy
scons -j $NCPU build=fast enable_objcryst=yes test
scons -j $NCPU build=fast enable_objcryst=yes prefix=$PREFIX install 

print "\
# diffpy.srreal --------------------------------------------------------------"
cd $SRCDIR/diffpy.srreal
scons -j $NCPU build=fast prefix=$PREFIX install

print "\
# sans/data_util -------------------------------------------------------------"
easy_install -UZN --prefix=$PREFIX ${SRCDIR}/sans/data_util

print "\
# sans/DataLoader ------------------------------------------------------------"
easy_install -UZN --prefix=$PREFIX ${SRCDIR}/sans/DataLoader

print "\
# sans/sansmodels ------------------------------------------------------------"
easy_install -UZN --prefix=$PREFIX ${SRCDIR}/sans/sansmodels

print "\
# sans/pr_inversion ----------------------------------------------------------"
easy_install -UZN --prefix=$PREFIX ${SRCDIR}/sans/pr_inversion

print "\
# diffpy.srfit ---------------------------------------------------------------"
easy_install -UZN --prefix=$PREFIX ${SRCDIR}/diffpy.srfit

# use patchelf to fix the RPATH in shared library objects 
# FIXME...
