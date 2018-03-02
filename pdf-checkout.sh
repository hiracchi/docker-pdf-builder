#!/bin/bash

# set -x
BASEDIR=`pwd`

HOSTS="github bitbucket"

GITHUB_PROTEINDF="git@github.com:ProteinDF/ProteinDF.git"
GITHUB_PROTEINDF_PYTOOLS="git@github.com:ProteinDF/ProteinDF_pytools.git"
GITHUB_PROTEINDF_BRIDGE="git@github.com:ProteinDF/ProteinDF_bridge.git"
GITHUB_QCLOBOT="git@github.com:ProteinDF/QCLObot.git"

BITBUCKET_PROTEINDF="git@bitbucket.org:hiracchi/proteindf.git"
BITBUCKET_PROTEINDF_PYTOOLS="git@bitbucket.org:hiracchi/proteindf_pytools.git"
BITBUCKET_PROTEINDF_BRIDGE="git@bitbucket.org:hiracchi/proteindf_bridge.git"
BITBUCKET_QCLOBOT="git@bitbucket.org:hiracchi/qclobot.git"

CLONE_DEVELOP="no"


show_help()
{
    echo "get the sources of the ProteinDF system"
    echo "${0} [ITEM]..."
    echo ""
    echo "ITEM: ProteinDF ProteinDF_bridge ProteinDF_pytools QCLObot"
    echo
    echo "OPTIONS:"
    echo "--develop: clone the develop branch."
}


clone()
{
    HOST=${1}
    NAME=${2}

    NAME_UPPERCASE=`echo ${NAME} | tr '[a-z]' '[A-Z]'`
    HOST_UPPERCASE=`echo ${HOST} | tr '[a-z]' '[A-Z]'`
    REPOS=`eval echo '$'${HOST_UPPERCASE}_${NAME_UPPERCASE}`

    if [ "x${CLONE_DEVELOP}" != "xyes" ]; then
        git clone --depth 1 ${REPOS} ${NAME}
    else
        # clone all for develop env.
        git clone ${REPOS} ${NAME}

        # setup git-flow
        (cd ${NAME}; \
         git fetch --all --prune; \
         git flow init -df; \

         # rename remote
         git remote rename origin ${HOST} \
             )
    fi
}


add_remote()
{
    HOST=${1}
    NAME=${2}

    NAME_UPPERCASE=`echo ${NAME} | tr '[a-z]' '[A-Z]'`
    HOST_UPPERCASE=`echo ${HOST} | tr '[a-z]' '[A-Z]'`
    REPOS=`eval echo '$'${HOST_UPPERCASE}_${NAME_UPPERCASE}`

    (cd ${NAME}; \
     git remote add ${HOST} ${REPOS}; \
     git fetch --all --prune; \
    )
}


checkout_develop()
{
    HOST=${1}
    NAME=${2}

    NAME_UPPERCASE=`echo ${NAME} | tr '[a-z]' '[A-Z]'`
    HOST_UPPERCASE=`echo ${HOST} | tr '[a-z]' '[A-Z]'`
    REPOS=`eval echo '$'${HOST_UPPERCASE}_${NAME_UPPERCASE}`

    (cd ${NAME}; \
     git checkout develop; \
     git branch -u ${HOST}/develop; \
     git pull --rebase;
    )
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

        '--develop')
            shift 1
            CLONE_DEVELOP="yes"
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

    clone github ${TARGET}

    if [ "x${CLONE_DEVELOP}" = "xyes" ]; then
        add_remote bitbucket ${TARGET}
        checkout_develop github ${TARGET}
    fi
    echo "Done."
done
