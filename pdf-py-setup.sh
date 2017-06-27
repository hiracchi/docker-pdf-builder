#!/bin/bash

export LANG=C

WORKDIR=${WORKDIR:-"/tmp"}
BRANCH=${BRANCH:-"master"}

checkout()
{
    REPOSITORY=$1
    BRANCH=$2
    
    echo "repository: ${REPOSITORY}"
    echo "branch: ${BRANCH}"

    git clone --depth 1 -b ${BRANCH} "${REPOSITORY}" .
}


# option ==============================================================
PROGNAME=$(basename $0)
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



# main =================================================================
(mkdir -p ${WORKDIR}/bridge;  cd ${WORKDIR}/bridge; \
 checkout "https://github.com/ProteinDF/ProteinDF_bridge.git"  "${BRANCH}"; \
 pdf-py-install.sh)
(mkdir -p ${WORKDIR}/pytools; cd ${WORKDIR}/pytools; \
 checkout "https://github.com/ProteinDF/ProteinDF_pytools.git" "${BRANCH}"; \
 pdf-py-install.sh)

