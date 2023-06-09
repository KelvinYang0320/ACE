#!/bin/bash
################################################
# This script build all the dependency         #
# for you which include gmp, ntl, barvinok     #
#  the details can also be found at:           #
#  https://repo.or.cz/w/barvinok.git           #
################################################

echo "------------------------------------"

echo "Create and Enter external/"
mkdir -p external; cd external
EXTERNAL_LIB=`pwd`
echo "Git clone NTL then Enter external/ntl/"
git clone https://github.com/libntl/ntl.git > /dev/null; cd ntl

echo "Enter external/ntl/src/ and Configure NTL"
cd src
./configure NTL_GMP_LIP=on PREFIX=$EXTERNAL_LIB SHARED=on > /dev/null

echo "Build and Install NTL"
make > /dev/null ; make install > /dev/null

echo "Leave back to external/"
cd ../..

echo "------------------------------------"

echo "Git clone Barvinok then Enter external/barvinok/"
git clone https://repo.or.cz/barvinok.git > /dev/null; cd barvinok
echo "Recursively Get sub modules"
WAIT_TIME=0
SUCCEED=1
until [[ $SUCCEED -eq 0 || $WAIT_TIME -eq 4 ]]; do
  ./get_submodules.sh > /dev/null
  SUCCEED=$?
  echo "sleep $WAIT_TIME seconds.."
  sleep $WAIT_TIME
  let WAIT_TIME=WAIT_TIME+1
done
# Clone ISL with isl_union_pw_qpolynomial_domain_reverse
# https://groups.google.com/g/isl-development/c/8nfe3MBUB6c
echo "[ISL] Checkout 7d198d0bc8c80cfe1f8b2e8946edcdc436b86bde"
cd ./isl
git pull
git checkout 7d198d0bc8c80cfe1f8b2e8946edcdc436b86bde
cd ..

echo "run autogen.sh"
sh autogen.sh > /dev/null

echo "Configure Barvinok"
./configure --prefix=$EXTERNAL_LIB --with-ntl-prefix=$EXTERNAL_LIB --enable-shared-barvinok > /dev/null

echo "Build and Install Barvinok"
make > /dev/null; make check > /dev/null; make install > /dev/null

echo "Leaving back to external/"
cd ..
echo "Remove NTL and Barvinok Package"
rm -rf barvinok ntl

echo "export LD_LIBRARY_PATH=`pwd`/lib:\${LD_LIBRARY_PATH}" >> ~/.bashrc
