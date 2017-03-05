#!/bin/bash

export LANG=C

if [ x${PDF_HOME} = x ]; then
    PDF_HOME="/usr/local/ProteinDF"
fi
if [ x${TMP} = x ]; then
    TMP=/tmp
fi

# show parameter
echo "PDF_HOME=${PDF_HOME}"
echo "SRCDIR=${SRCDIR}"
echo "TMP=${TMP}"

# checkout ============================================================
checkout-pdf()
{
    if [ x${REPOSITORY} = x ]; then
        REPOSITORY="https://github.com/ProteinDF/ProteinDF.git"
    fi
    if [ x${BRANCH} = x ]; then
        BRANCH="master"
    fi
    if [ x${TRAVIS_BRANCH} != x ]; then
        BRANCH="${TRAVIS_BRANCH}"
    fi
    
    echo "repository: ${REPOSITORY}"
    echo "branch: ${BRANCH}"
    
    git clone -b ${BRANCH} "${REPOSITORY}"
}


# build setup =========================================================
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
 --prefix=${PDF_HOME} \
 --enable-parallel \
 --with-blas \
 --with-lapack \
 --with-scalapack \
 "


# build ===============================================================
if [ x${SRCDIR} != x ]; then
    cd ${SRCDIR}
fi

if [ -f bootstrap.sh ]; then
    rm -rf autom4te.cache
    ./bootstrap.sh
fi

mkdir -p ${TMP}/build
cd ${TMP}/build
${SRCDIR}/configure ${CONFIGURE_OPT} 2>&1 | tee out.configure
make -j 3 2>&1 | tee out.make
make install 2>&1 | tee out.make_install

