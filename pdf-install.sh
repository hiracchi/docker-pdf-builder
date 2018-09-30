#!/bin/bash

set -e # stop on error
#set -u # inform undefined variables
#set -x # output command

TEMP=/tmp
BRANCH="master"

# option ==============================================================
declare -a ARGV=()
OPT_W=""
OPT_CLONE_ONLY=""
OPT_BRANCH=""
OPT_CMAKE=""

for OPT in "$@"; do
    case "$OPT" in
        '-w'|'--work')
            if [[ -z "${2}" ]] || [[ "${2}" =~ ^-+ ]]; then
                echo "$PROGNAME: option requires an argument -- ${1}" 1>&2
                exit 1
            fi
            OPT_W="$2"
            shift 2
            ;;

        '--branch')
            if [[ -z "${2}" ]] || [[ "${2}" =~ ^-+ ]]; then
                echo "$PROGNAME: option requires an argument -- ${1}" 1>&2
                exit 1
            fi
            OPT_BRANCH="$2"
            shift 2
            ;;

        '--'|'-')
            shift 1
            ARGV+=( "$@" )
            break
            ;;
        -*)
            echo "unknown option: ${1}"
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

WORKDIR=""
if [ -n "${OPT_W}" ]; then
    WORKDIR=${OPT_W}
fi

if [ -n "${OPT_BRANCH}" ]; then
    BRANCH="${OPT_BRANCH}"
fi


# MAIN =================================================================
if [ "x${WORKDIR}" == x ]; then
    WORKDIR=${TEMP}
fi
echo "WORKDIR=${WORKDIR}"

for CMD in ${ARGV[@]}; do
    case "${CMD}" in
        "ProteinDF" | "ProteinDF_bridge" | "ProteinDF_pytools" | "QCLObot")
            (cd ${WORKDIR}; \
             pdf-checkout.sh --branch ${BRANCH} ${CMD}; \
             cd ${WORKDIR}/${CMD}; pdf-build.sh \
             )
            ;;

        *)
            echo "ignore unknown command: ${CMD}"
            ;;
    esac
done
