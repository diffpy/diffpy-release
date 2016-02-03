DIFFPY-CMI

Software framework for complex modeling of structures from diffraction data

This release includes Python and C++ modules developed by the DiffPy team
and the required external software dependencies.

Python Libraries:

* diffpy.srfit -- setup, control and evaluation of multi-contribution fits.
* diffpy.srreal -- calculators for pair-interaction quantities such as pair
  distribution function (PDF), bond lengths, and bond valence sums (BVS).
* diffpy.Structure -- storage and manipulation of crystal structure data
  and space group symmetry utilities.
* diffpy.utils -- shared utilities such as parsing of text data files.
* pyobjcryst -- Python bindings to the ObjCryst++ Object-Oriented
  Crystallographic Library
* PyCifRW -- support for CIF (Crystallographic Information Format) files
* periodictable -- access to the periodic table of elements data in Python

C++ Libraries:

* libdiffpy -- calculation of PDF, BVS and other pair-interaction quantities.
* libobjcryst -- ObjCryst++ Object-Oriented Crystallographic Library packaged
  for installation as a shared library.
* CxxTest -- testing framework for C++ codes.


REQUIREMENTS

Linux or Mac OS X with the following packages from system software manager:

(a) Ubuntu or Debian Linux:

    sudo apt-get install \
        libgsl0-dev libboost-all-dev python-dev python-setuptools \
        python-numpy python-scipy python-matplotlib python-lxml ipython \
        build-essential scons git zsh
        
(b) Fedora Linux:

    sudo yum install \
        gsl-devel boost-devel python-devel python-setuptools \
        numpy scipy  python-matplotlib python-lxml python-ipython-notebook \
        gcc-c++ scons git zsh

(c) Mac OS X with MacPorts (this may run for a while):

    sudo port install \
        python27 py27-setuptools py27-ipython py27-lxml \
        gsl boost py27-numpy py27-scipy py27-matplotlib scons git-core

    sudo port select --set ipython ipython27
    sudo port select --set python python27

    Important: When done, adjust the shell environment so that MacPorts Python
    is the first in the PATH:

    export PATH=/opt/local/bin:${PATH}


INSTALLATION

Run "./install" in a terminal and follow the prompts.  When completed, run
"./runtests.sh" to verify the installation.

If you prefer to install manually, create symbolic link to the diffpy_cmi.pth
file in some Python directory that processes .pth files.  Note it is essential
to use the symbolic link, making a copy of the .pth file would not work.

For a single-user installation the preferred pth directory can be found using

    python -c 'import site; print site.USER_SITE'

whereas for a system-wide installation the standard pth locations are

    python -c 'import site; print site.getsitepackages()'


UPGRADE

DiffPy source packages included in this distribution can be updated to
the latest versions from online source repositories by running

    ./install --update[=steps]

where the optional steps allow to do updates only for some rather
than all source codes.  Use "./install -n --update" to display the
list of steps without making any changes.

The updated sources need to be re-compiled and activated using

    ./install --build[=steps]

Similarly as for the update action, "./install -n --build" displays
the build steps without performing them.  Finally, use "./install --help"
for a short summary of all options for the install script.


CONTACTS

If you need help with installing this software, please check discussions
or post your question at https://groups.google.com/d/forum/diffpy-dev.

For more information on DiffPy-CMI please visit the project web-page

http://www.diffpy.org

or email Prof. Simon Billinge at sb2896@columbia.edu.
