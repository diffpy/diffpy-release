(1) Install the required dependencies from the command line by using a suitable package manager.

	For Ubuntu use apt-get:

	sudo apt-get install \
    	libgsl0-dev libboost-all-dev python-dev \
    	python-setuptools python-numpy python-scipy \
    	python-matplotlib python-lxml ipython \
    	scons git zsh
	
	For Fedora use yum:

	sudo yum install \
    	gsl-devel boost-devel python-devel
    	python-setuptools numpy scipy  \
    	python-matplotlib python-lxml \
    	python-ipython-notebook scons git zsh

(2) To install diffpy-cmi, run

    ./install
    
    You should first view and agree the license agreement. Then you can 
    choose the Python directory to install. 

	If you prefer to install it manually, follow the instructions below. 
    For a one-user installation determine the Python directory for user
    files, create it if it does not exist yet, and add there a symbolic
    link to the diffpy_cmi.pth file:

    D="$(python -c 'import site; print site.USER_SITE')"
    mkdir -p "$D"
    ln -si $PWD/diffpy_cmi.pth "$D"/

    For a system-wide installation create symbolic link in the directory
    for system-wide Python packages:

    sudo ln -si $PWD/diffpy_cmi.pth /usr/local/lib/python2.7/dist-packages/

    Note it is essential to use the symbolic link.  Making a copy of the
    pth file would not work.

(3) Test the installation with

    ./runtests.sh

(4, optional) update and rebuild:

    ./install --update[=steps]  
    
    perform all or selected software updates from online source repositories.  
    Update steps are comma separated integers or ranges such as '1,3,5-6'.  
    Use option -n to display the steps.
    
    ./install --build[=steps]   
    
    rebuild all or specified packages from sources in the src folder.  Use 
    option -n to display the build steps.
