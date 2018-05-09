#!/bin/bash

# set -x
BASEDIR=`pwd`

HTTPS_PROTEINDF="https://github.com/ProteinDF/ProteinDF.git"
HTTPS_PROTEINDF_PYTOOLS="https://github.com/ProteinDF/ProteinDF_pytools.git"
HTTPS_PROTEINDF_BRIDGE="https://github.com/ProteinDF/ProteinDF_bridge.git"
HTTPS_QCLOBOT="https://github.com/ProteinDF/QCLObot.git"
HTTPS_PROTEINDF_TEST="https://github.com/ProteinDF/ProteinDF_test.git"

BRANCH="master"


show_help()
{
    echo "get the sources of the ProteinDF system"
    echo "${0} [ITEM]..."
    echo ""
    echo "ITEM: ProteinDF ProteinDF_bridge ProteinDF_pytools QCLObot ProteinDF_test"
}


clone()
{
    NAME=${1}

    NAME_UPPERCASE=`echo ${NAME} | tr '[a-z]' '[A-Z]'`
    REPOS=`eval echo '$'HTTPS_${NAME_UPPERCASE}`

    git clone -b ${BRANCH} --depth 1 ${REPOS} ${NAME}
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

        '--branch')
            if [[ -z "${2}" ]] || [[ "${2}" =~ ^-+ ]]; then
                echo "$PROGNAME: option requires an argument -- ${1}" 1>&2
                exit 1
            fi
            BRANCH="$2"
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


# MAIN -----------------------------------------------------------------
if [ ${ARGC} -eq 0 ]; then
    show_help
    exit 1
fi


for TARGET in ${ARGV[@]}; do
    echo ">>>> ${TARGET}"
    clone ${TARGET}
    echo "Done."
done
