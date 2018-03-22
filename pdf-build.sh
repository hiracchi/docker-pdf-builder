#!/bin/bash
# set -eux
umask 0000

SRCDIR=`pwd`
WORKDIR=/tmp
UNBUFFER=
if [ `which unbuffer` ]; then
    UNBUFFER="unbuffer"
fi

# ======================================================================
# FUNCTIONS
# ======================================================================
setup_pytools()
{
    PIP_CMD="pip"
    if type pip3 2>&1 > /dev/null; then
        PIP_CMD="pip3"
    fi

    eval "${PIP_CMD} install --upgrade ."
}


# cmake版
build_pdf_cmake()
{
    if [ -d "${WORKDIR}/build" ]; then
        rm -rf "${WORKDIR}/build"
    fi
    mkdir -p "${WORKDIR}/build"
    cd "${WORKDIR}/build"

    # cmake setup
    CMAKE_ENV_OPTS=`env2cmake.py`
    eval "cmake -DCMAKE_INSTALL_PREFIX=\"${PDF_HOME}\" ${CMAKE_ENV_OPTS}" "${SRCDIR}" 2>&1 | tee out.cmake

    ${UNBUFFER} make 2>&1 | tee out.make
    ${UNBUFFER} make install 2>&1 | tee out.make_install
}


build_pdf_configure()
{
    #CONFIGURE_OPT=" \
    #    --enable-debug \
    #    --enable-cppunit
    BASEDIR=`pwd`

    if [ -d autom4te.cache ]; then
        rm -rf autom4te.cache
    fi

    if [ -f bootstrap.sh ]; then
        ./bootstrap.sh
    fi

    ./configure \
        --prefix=${PDF_HOME} \
        ${CONFIGURE_OPT} \
        --enable-parallel \
        --with-blas="${BLAS_LIBRARIES}" \
        --with-lapack="${LAPACK_LIBRARIES}" \
        --with-scalapack="${SCALAPACK_LIBRARIES}" \
        2>&1 | tee out.configure
    make -j 3 2>&1 | tee out.make
    make install 2>&1 | tee out.make_install
}


# ======================================================================
# option
# ======================================================================
declare -a ARGV=()

for OPT in "$@"; do
    case "$OPT" in
        '-h'|'--help')
            show_help
            exit 0
            ;;

        '-d'|'--debug')
            CMAKE_BUILD_TYPE="Debug"
            ;;

        '-v'|'--verbose')
            CMAKE_VERBOSE_MAKEFILE="1"
            ;;

        '-s'|'--srcdir')
            if [[ -z "${2}" ]] || [[ "${2}" =~ ^-+ ]]; then
                echo "$PROGNAME: option requires an argument -- ${1}" 1>&2
                exit 1
            fi
            SRCDIR="$2"
            shift 2
            ;;

        '-w'|'--workdir')
            if [[ -z "${2}" ]] || [[ "${2}" =~ ^-+ ]]; then
                echo "$PROGNAME: option requires an argument -- ${1}" 1>&2
                exit 1
            fi
            WORKDIR="$2"
            shift 2
            ;;

        '--'|'-')
            shift 1
            ARGV+=( "$@" )
            break
            ;;
        -*)
            echo "unknown option: ${1}"
            show_help
            exit 1
            ;;
        *)
            if [[ ! -z "$1" ]] && [[ ! "$1" =~ ^-+ ]]; then
                ARGV=("${ARGV[@]}" "$1")
                shift 1
            fi
            ;;
    esac
done
ARGC=${#ARGV[@]}
#echo "ARGC=${ARGC}"
#echo "ARGV[@]=${ARGV[@]}"


# ======================================================================
# MAIN
# ======================================================================
cd ${SRCDIR}

if [ "x${PDF_HOME}" = x ]; then
   echo "environment variable \"PDF_HOME\" is not set. stop."
   exit 1
fi
echo "PDF_HOME=${PDF_HOME}"


if [ -f setup.py ]; then
    echo "build python application ..."
    setup_pytools
elif [ -f CMakeLists.txt ]; then
    echo "build by using CMake ..."
    build_pdf_cmake
elif [ -f bootstrap.sh -o -f configure ]; then
    echo "build by using automake ..."
    build_pdf_configure
else
    echo "cannot find how to build. stop."
    exit 1
fi
