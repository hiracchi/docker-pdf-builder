#!/bin/bash

export LANG=C

# setup parameters =====================================================
export PDF_HOME=${PDF_HOME:-"/usr/local/ProteinDF"}

REPOSITORY=${REPOSITORY:-"https://github.com/ProteinDF/ProteinDF_test.git"}
BRANCH=${BRANCH:-"master"}
TMP=${TMP:-"/tmp"}

WORKDIR=${WORKDIR:-"${TMP}/pdftest"}

# checkout ============================================================
checkout()
{
    WORKDIR="."
    if [ x${1} != x ]; then
        WORKDIR="${1}"
    fi
    echo "repository: ${REPOSITORY}"
    echo "branch: ${BRANCH}"
    echo "WORKDIR: ${WORKDIR}"

    git clone -b ${BRANCH} "${REPOSITORY}" "${WORKDIR}"
}


# option ==============================================================
for OPT in "$@"; do
    case "$OPT" in
        '-b'|'--branch')
            if [[ -z "${2}" ]] || [[ "${2}" =~ ^-+ ]]; then
                echo "$PROGNAME: option requires an argument -- ${1}" 1>&2
                exit 1
            fi
            OPT_B="$2"
            shift 2
            ;;

        '-w'|'--workdir')
            if [[ -z "${2}" ]] || [[ "${2}" =~ ^-+ ]]; then
                echo "$PROGNAME: option requires an argument -- ${1}" 1>&2
                exit 1
            fi
            OPT_W="$2"
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

if [ -n "${OPT_B}" ]; then
    BRANCH=${OPT_B}
fi
if [ -n "${OPT_W}" ]; then
    WORKDIR=${OPT_W}
fi

# do test ==============================================================
echo "PDF_HOME=${PDF_HOME}"
echo "test workdir: ${WORKDIR}"
if [ -d ${WORKDIR} ]; then
    rm -rf ${WORKDIR}
fi

echo "checkout ..."
checkout ${WORKDIR}

cd "${WORKDIR}"
for i in ${param[@]}; do
    echo "run test (check_${i})..."
    make check_${i}
done

