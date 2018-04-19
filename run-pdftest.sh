#!/bin/bash

CONTAINER_NAME="pdf-runner"
PDF_BUILDER_VER="develop"
BRANCH=develop

docker rm -f ${CONTAINER_NAME}
docker run -d --name ${CONTAINER_NAME} "hiracchi/pdf-builder:${PDF_BUILDER_VER}"
docker exec -it ${CONTAINER_NAME} pdf-checkout.sh --branch ${BRANCH} ProteinDF
docker exec -it ${CONTAINER_NAME} pdf-checkout.sh --branch ${BRANCH} ProteinDF_bridge
docker exec -it ${CONTAINER_NAME} pdf-checkout.sh --branch ${BRANCH} ProteinDF_pytools

docker exec -it ${CONTAINER_NAME} pdf-build.sh --srcdir /work/ProteinDF
docker exec -it ${CONTAINER_NAME} pdf-build.sh --srcdir /work/ProteinDF_bridge
docker exec -it ${CONTAINER_NAME} pdf-build.sh --srcdir /work/ProteinDF_pytools

docker exec -it ${CONTAINER_NAME} pdf-check.sh --branch develop serial_dev
