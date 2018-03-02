#!/bin/bash

PDF_RUNNER="pdf-runner"
BRANCH=develop

# docker rm -f ${PDF_RUNNER}
docker run -d --name ${PDF_RUNNER} -v "${PWD}:/work" hiracchi/pdf-builder
docker exec -it ${PACKAGE} pdf-install.sh --branch master ProteinDF ProteinDF_bridge ProteinDF_pytools QCLObot
docker exec -it ${PDF_RUNNER} pdf-check.sh --branch develop serial_dev
