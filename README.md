# docker-pdfdev

[![](https://images.microbadger.com/badges/image/hiracchi/pdf-builder.svg)](https://microbadger.com/images/hiracchi/pdf-builder "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/hiracchi/pdf-builder.svg)](https://microbadger.com/images/hiracchi/pdf-builder "Get your own version badge on microbadger.com")

A Dockerfile to build the ProteinDF

* Usage

The Docker image is prepared at Docker HUB.

```
$ docker pull hiracchi/pdf-builder
```

Then, execute the following script after you set the ProteinDF source code.
You may get ProteinDF execution files in the `$LOCAL_PDF_HOME` directory.

```bash
#!/bin/bash

LOCAL_PDF_HOME=${PWD}/tmp/ProteinDF

if [ ! -d ${LOCAL_PDF_HOME} ]; then
    mkdir -p ${LOCAL_PDF_HOME}
fi
    
USER_ID=`id -u`
GROUP_ID=`id -g`
    
docker run --rm -it \
  -v "${PWD}:/home/pdf/local/src/ProteinDF" \
  -v "${LOCAL_PDF_HOME}:/home/pdf/local/ProteinDF" \
  -u=${USER_ID}:${GROUP_ID} \
  hiracchi/pdf-builder $@
```

