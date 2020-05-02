#!/bin/bash

PACKAGE="hiracchi/pdf-builder"
CONTAINER_NAME="pdf-runner"
PDF_BUILDER_VER="develop"
PDF_BRANCH=develop
BRIDGE_BRANCH=develop
TOOLS_BRANCH=develop

docker rm -f ${CONTAINER_NAME}
docker run -d --name ${CONTAINER_NAME} "${PACKAGE}:${PDF_BUILDER_VER}"
docker exec -it ${CONTAINER_NAME} pdf-checkout.sh --branch ${PDF_BRANCH} ProteinDF
docker exec -it ${CONTAINER_NAME} pdf-checkout.sh --branch ${BRIDGE_BRANCH} ProteinDF_bridge
docker exec -it ${CONTAINER_NAME} pdf-checkout.sh --branch ${TOOLS_BRANCH} ProteinDF_pytools

docker exec -it ${CONTAINER_NAME} pdf-build.sh --srcdir /work/ProteinDF
docker exec -it ${CONTAINER_NAME} pdf-build.sh --srcdir /work/ProteinDF_bridge
docker exec -it ${CONTAINER_NAME} pdf-build.sh --srcdir /work/ProteinDF_pytools

docker exec -it ${CONTAINER_NAME} pdf-check.sh --branch develop serial_dev
