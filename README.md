# docker-pdfdev

[![](https://images.microbadger.com/badges/image/hiracchi/pdf-builder.svg)](https://microbadger.com/images/hiracchi/pdf-builder "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/hiracchi/pdf-builder.svg)](https://microbadger.com/images/hiracchi/pdf-builder "Get your own version badge on microbadger.com")

A Dockerfile to build the ProteinDF

* Usage

The Docker image is prepared at Docker HUB.

```
$ docker pull hiracchi/pdf-builder
```

Then, execute the following script, which is included as "run-pdftest.sh", 
after you set the ProteinDF source code at the current directory.
You may get ProteinDF execution files in the `/opt/ProteinDF` directory in the container.


```bash
#!/bin/bash

PDF_RUNNER="pdf-runner"

docker rm -f ${PDF_RUNNER} 2>&1 > /dev/null
docker run -d --name ${PDF_RUNNER} -v "${PWD}:/work" hiracchi/pdf-builder
docker exec -it ${PDF_RUNNER} pdf-py-setup.sh --work /tmp --branch develop
docker exec -it ${PDF_RUNNER} pdf-builder.sh -o /tmp/pdf
docker exec -it ${PDF_RUNNER} pdf-check.sh --branch develop serial_dev
```

