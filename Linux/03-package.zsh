#!/bin/zsh -f

srfitpath=srfit-$(date +%F)-$(uname -s)-$(uname -i)
mkdir $srfitpath
mv bin $srfitpath/bin
mv include $srfitpath/include
mv lib $srfitpath/lib
mv share $srfitpath/share
mv src/cctbx/cctbx_build $srfitpath/src/cctbx/cctbx_build

cp /usr/lib/libboost_python-py27.so.1.46.1 $srfitpath/lib
cp /usr/lib/libboost_serialization.so.1.46.1 $srfitpath/lib
cp diffpy-u12x64.pth $srfitpath/diffpy-u12x64.pth
cp INSTALL.txt $srfitpath/INSTALL.txt
cp runtests.sh $srfitpath/runtests.sh

mkdir -p $srfitpath/src/cctbx
cp src/cctbx/cctbx_bundle.tar.gz $srfitpath/src/cctbx
./01-fetchsources.zsh $srfitpath/src

rm -rf $srfitpath/src/cctbx/cctbx_bundle.tar.gz

tar jcvf $srfitpath.tar.bz2 $srfitpath
