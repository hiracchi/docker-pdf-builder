#!/bin/bash

export LANG=C

# setup parameters =====================================================
export PDF_HOME=${PDF_HOME:-"/usr/local/ProteinDF"}
SRCDIR=${SRCDIR:-`pwd`}

REPOSITORY=${REPOSITORY:-"https://github.com/ProteinDF/ProteinDF.git"}
BRANCH=${BRANCH:-"master"}
if [ x${TRAVIS_BRANCH} != x ]; then
    BRANCH="${TRAVIS_BRANCH}"
fi
TMP=${TMP:-"/tmp"}


# option ==============================================================
for OPT in "$@"; do
    case "$OPT" in
        '-o'|'--out-of-source')
            if [[ -z "${2}" ]] || [[ "${2}" =~ ^-+ ]]; then
                echo "$PROGNAME: option requires an argument -- ${1}" 1>&2
                exit 1
            fi
            OPT_O="$2"
            shift 2
            ;;
        
        '-s'|'--source')
            if [[ -z "${2}" ]] || [[ "${2}" =~ ^-+ ]]; then
                echo "$PROGNAME: option requires an argument -- ${1}" 1>&2
                exit 1
            fi
            OPT_S="$2"
            shift 2
            ;;
        
        -*)
            echo "unknown option: ${1}"
            exit 1
            ;;
        *)
            shift
            ;;
    esac
done

if [ -n "${OPT_S}" ]; then
    SRCDIR=${OPT_S}
fi
OUT_OF_SOURCE=${OPT_O}


# checkout ============================================================
checkout()
{
    echo "repository: ${REPOSITORY}"
    echo "branch: ${BRANCH}"

    cd ${SRCDIR}
    git clone -b ${BRANCH} "${REPOSITORY}" .
    cd ${SRCDIR}/ProteinDF
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
#export MPICXX=
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
echo "install to PDF_HOME=${PDF_HOME}"
echo "SRCDIR=${WORKDIR}"

cd ${SRCDIR}
if [ ! -f ${SRCDIR}/configure ]; then
    rm -rf autom4te.cache
    ${SRCDIR}/bootstrap.sh
fi

if [ x${OUT_OF_SOURCE} != x ]; then
    mkdir -p ${OUT_OF_SOURCE}
    cd ${OUT_OF_SOURCE}
fi

${SRCDIR}/configure ${CONFIGURE_OPT} 
make -j 3 && make install 

