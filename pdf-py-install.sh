#!/bin/bash

export LANG=C

# setup parameters =====================================================
export PDF_HOME=${PDF_HOME:-"/usr/local/ProteinDF"}
SRCDIR=${SRCDIR:-`pwd`}

BRANCH=${BRANCH:-"master"}
TMP=${TMP:-"/tmp"}


# checkout ============================================================
checkout()
{
    echo "repository: ${REPOSITORY}"
    echo "branch: ${BRANCH}"

    cd ${SRCKDIR}
    git clone -b ${BRANCH} "${REPOSITORY}" .
}


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
        
        '--'|'-')
            shift 1
            param+=( "$@" )
            break
            ;;
        -*)
            echo "unknown option: ${OPT}"
            exit 1
            ;;
        *)
            if [[ ! -z "$1" ]] && [[ ! "$1" =~ ^-+ ]]; then
                param+=( "$1" )
                shift 1
            fi
            ;;
    esac
done

if [ -n "${OPT_S}" ]; then
    SRCDIR=${OPT_S}
fi
OUT_OF_SOURCE=${OPT_O}


# build ===============================================================
echo "install to PDF_HOME=${PDF_HOME}"

cd ${SRCDIR}
if [ -n "${OUT_OF_SOURCE}" ]; then
    BUILD_OPT="--build-base ${OUT_OF_SOURCE}"
fi
python3 setup.py build ${BUILD_OPT} install --prefix=${PDF_HOME}

