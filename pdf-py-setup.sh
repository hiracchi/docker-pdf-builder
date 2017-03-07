#!/bin/bash

export LANG=C

BRANCH=${BRANCH:-"master"}

checkout()
{
    REPOSITORY=$1
    BRANCH=$2
    
    echo "repository: ${REPOSITORY}"
    echo "branch: ${BRANCH}"

    git clone -b ${BRANCH} "${REPOSITORY}" .
}

(mkdir -p /tmp/bridge;  cd /tmp/bridge; \
 checkout "https://github.com/ProteinDF/ProteinDF_bridge.git"  "${BRANCH}"; \
 pdf-py-install.sh)
(mkdir -p /tmp/pytools; cd /tmp/pytools; \
 checkout "https://github.com/ProteinDF/ProteinDF_pytools.git" "${BRANCH}"; \
 pdf-py-install.sh)
