PACKAGE=pdf-builder
PDF_BUILDER_VER=latest
BRANCH=develop

.PHONY: build run exec

build:
	docker build -t "hiracchi/${PACKAGE}:latest" .

run:
	docker run -d --rm \
		--name ${PACKAGE} \
		"hiracchi/${PACKAGE}:${PDF_BUILDER_VER}"

stop:
	docker rm -f ${PACKAGE}

exec:
	docker exec -it ${PACKAGE} /bin/bash

pdf-check:
	docker exec -it ${PACKAGE} pdf-install.sh --branch master pytools bridge qclobot
	docker exec -it ${PACKAGE} pdf-install.sh --branch ${BRANCH} --use-cmake pdf
	docker exec -it ${PACKAGE} pdf-check.sh --branch develop serial_dev
