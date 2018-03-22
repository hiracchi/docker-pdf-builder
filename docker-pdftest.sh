#!/bin/bash

BRANCH=master
TEST_BRANCH=master

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

        '-b'|'--branch')
            if [[ -z "${2}" ]] || [[ "${2}" =~ ^-+ ]]; then
                echo "$PROGNAME: option requires an argument -- ${1}" 1>&2
                exit 1
            fi
            BRANCH="$2"
            shift 2
            ;;

        '-t'|'--test-branch')
            if [[ -z "${2}" ]] || [[ "${2}" =~ ^-+ ]]; then
                echo "$PROGNAME: option requires an argument -- ${1}" 1>&2
                exit 1
            fi
            TEST_BRANCH="$2"
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

# build packages --
# /work/ProteinDF directory should be mounted by `docker run`
pdf-checkout.sh --branch ${BRANCH} ProteinDF_bridge
pdf-checkout.sh --branch ${BRANCH} ProteinDF_pytools

pdf-build.sh --workdir /work/ProteinDF # mounted by docker
pdf-build.sh --workdir /work/ProteinDF_bridge
pdf-build.sh --workdir /work/ProteinDF_pytools


# run test --
# TARGET = serial, serial_dev, etc.
for TARGET in ${ARGV[@]}; do
    echo ">>>> ${TARGET}"
    pdf-check.sh -w /work/pdf-test --branch ${TEST_BRANCH} ${TARGET}
    echo "Done."
done
