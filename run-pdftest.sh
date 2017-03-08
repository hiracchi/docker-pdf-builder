#!/bin/bash

PDF_RUNNER="pdfrunner"

docker rm -f ${PDF_RUNNER}
docker run -d --name ${PDF_RUNNER} -v "${PWD}:/work" hiracchi/pdf-builder
docker exec -it ${PDF_RUNNER} pdf-py-setup.sh --work /tmp --branch develop
docker exec -it ${PDF_RUNNER} pdf-builder.sh -o /tmp/pdf
docker exec -it ${PDF_RUNNER} pdf-check.sh --branch develop serial_dev



