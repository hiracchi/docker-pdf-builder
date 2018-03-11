#!/bin/bash

BRANCH=develop

# /work/ProteinDF directory should be mounted by `docker run`
pdf-checkout.sh --branch ${BRANCH} ProteinDF_bridge
pdf-checkout.sh --branch ${BRANCH} ProteinDF_pytools

pdf-build.sh --workdir /work/ProteinDF # mounted by docker
pdf-build.sh --workdir /work/ProteinDF_bridge
pdf-build.sh --workdir /work/ProteinDF_pytools

pdf-check.sh -w /work/pdf-test --branch ${BRANCH} serial 
