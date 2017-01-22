FROM hiracchi/openssh:latest
MAINTAINER Toshiyuki HIRANO <hiracchi@gmail.com>

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/hiracchi/docker-pdfdev" \
      org.label-schema.version=$VERSION

# packages install
RUN apk --update add --no-cache --virtual build-dependencies \
  make automake autoconf libtool cmake \
  file unzip flex build-base \
  gcc g++ gfortran \
  && apk --update add --no-cache --virtual build-tool \
  curl git \
  perl \
  python3 python3-dev \
  lapack lapack-dev \
  libgcrypt-dev \
  freetype-dev \
  cppunit \
  emacs-nox \
  && apk --update add --no-cache --virtual interactive \
  bash openssh \
  && rm -rf /var/cache/apk/*

# setup python modules
RUN ln -s /usr/include/locale.h /usr/include/xlocale.h
RUN pip3 install --upgrade pip \
  && pip3 install \
  PyYAML msgpack-python \
  numpy scipy matplotlib \
  Jinja2 BeautifulSoup4 

# HDF5  

# openmpi & scalapack
WORKDIR /tmp
RUN curl -O "https://www.open-mpi.org/software/ompi/v2.0/downloads/openmpi-2.0.1.tar.bz2" \
  && tar xvfj openmpi-2.0.1.tar.bz2 \
  && cd openmpi-2.0.1 && mkdir build && cd build \
  && ../configure --enable-orterun-prefix-by-default \
  && make && make install \
  && cd /tmp \
  && curl -O "http://www.netlib.org/scalapack/scalapack-2.0.2.tgz" \
  && tar xvfz scalapack-2.0.2.tgz \
  && cd scalapack-2.0.2 && mkdir build && cd build \
  && cmake .. \
  && make && make install \
  && rm -rf /tmp/*

# service
#CMD ["/usr/sbin/sshd -D -f /etc/ssh/sshd_config"]

