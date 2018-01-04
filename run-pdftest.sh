#!/bin/bash

PDF_RUNNER="pdf-runner"
BRANCH=develop

# docker rm -f ${PDF_RUNNER}
docker run -d --name ${PDF_RUNNER} -v "${PWD}:/work" hiracchi/pdf-builder
docker exec -it ${PACKAGE} pdf-install.sh --branch master pytools bridge qclobot
docker exec -it ${PACKAGE} pdf-install.sh --branch ${BRANCH} --use-cmake pdf
docker exec -it ${PDF_RUNNER} pdf-check.sh --branch develop serial_dev
