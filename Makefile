PACKAGE=pdf-builder
TAG=develop
BRANCH=master

.PHONY: build run exec

build:
	docker build -t "hiracchi/${PACKAGE}:${TAG}" .


start:
	docker run -d --rm \
		--name ${PACKAGE} \
		"hiracchi/${PACKAGE}:${TAG}"

stop:
	docker rm -f ${PACKAGE}

exec:
	docker exec -it ${PACKAGE} /bin/bash

pdf-check:
	docker exec -it ${PACKAGE} pdf-install.sh --branch master pytools bridge qclobot
	docker exec -it ${PACKAGE} pdf-install.sh --branch ${BRANCH} --use-cmake pdf
	docker exec -it ${PACKAGE} pdf-check.sh --branch develop serial_dev
