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
    echo "repository: ${REPOSITORY}"
    echo "branch: ${BRANCH}"

    git clone -b ${BRANCH} "${REPOSITORY}" .
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
        
        '-w'|'--work')
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
if [ ! -d ${WORKDIR} ]; then
    mkdir -p ${WORKDIR}
fi
cd ${WORKDIR}

echo "checkout ..."
checkout

for i in ${param[@]}; do
    echo "run test (check_${i})..."
    PDF_TEST_ARGS="--simple" make check_${i}
done

