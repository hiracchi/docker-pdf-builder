#!/bin/bash

export LANG=C
MY_PREFIX=${HOME}/local/ProteinDF

export F77=gfortran
export FC=gfortran
export CC=gcc
export CXX=g++
export CFLAGS=" \
 -Wall -O3 \
 -fopenmp \
 -DMPICH_IGNORE_CXX_SEEK \
 "
export CXXFLAGS="${CFLAGS} -std=c++11"
export CXXFLAGS=${CFLAGS}
#export MPICXX=${HOME}/local/gnu/openmpi/bin/mpicxx
export LIBS="-lgfortran -lm -static-libgcc"

export BLAS_LIBS="-lblas"
export LAPACK_LIBS="-llapack"
export SCALAPACK_LIBS="-lscalapack-openmpi -lblacs-openmpi -lblacsCinit-openmpi -lblacsF77init-openmpi -lblacs-openmpi"


CONFIGURE_OPT=" \
 --enable-parallel \
 --with-blas \
 --with-lapack \
 --with-scalapack \
 "
rm -rf autom4te.cache
./bootstrap.sh

./configure --prefix=${MY_PREFIX} ${CONFIGURE_OPT} 2>&1 | tee out.configure

make -j 3 2>&1 | tee out.make
make install 2>&1 | tee out.make_install


