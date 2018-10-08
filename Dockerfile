FROM hiracchi/ubuntu-ja:18.04

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/hiracchi/docker-pdf-builder" \
      org.label-schema.version=$VERSION \
      maintainer="Toshiyuki Hirano <hiracchi@gmail.com>"

ARG PDF_HOME="/opt/ProteinDF"
ARG WORKDIR="/work"


# packages =============================================================
RUN apt-get update \
  && apt-get install -y \
  sudo \
  build-essential pkg-config ca-certificates \
  vim less \
  git automake autoconf libtool cmake \
  liblapack-dev \
  openmpi-bin libopenmpi-dev \
  libblacs-mpi-dev libscalapack-mpi-dev \
  libclblas-dev \
  libeigen3-dev \
  clinfo opencl-headers libclc-dev mesa-opencl-icd \
  libboost-all-dev \
  hdf5-tools \
  libhdf5-dev \
  libhdf5-openmpi-dev \
  \
  python3-dev python3-pip \
  python3-numpy python3-scipy python3-pandas \
  python3-matplotlib \
  python3-yaml python3-msgpack \
  python3-jinja2 \
  python3-sklearn-lib \
  python3-requests python3-bs4 \
  python3-h5py python3-hdf5storage \
  && apt-get clean && apt-get autoclean \
  && rm -rf /var/lib/apt/lists/*


# viennacl-dev =========================================================
RUN set -x \
  && cd /tmp \
  && git clone "https://github.com/viennacl/viennacl-dev.git" \
  && mkdir -p /tmp/viennacl-dev/build \
  && cd /tmp/viennacl-dev/build \
  && cmake .. \
  && make \
  && make install


# google-test ==========================================================
RUN set -x \
  && cd /tmp \
  && git clone "https://github.com/google/googletest.git" \
  && mkdir -p /tmp/googletest/build \
  && cd /tmp/googletest/build \
  && cmake .. \
  && make \
  && make install \
  && rm -rf /tmp/googletest


# entrypoint ===========================================================
COPY docker-*.sh pdf-*.sh env2cmake.py /usr/local/bin/
WORKDIR ${WORKDIR}
ENV PDF_HOME="${PDF_HOME}" PATH="${PATH}:${PDF_HOME}/bin"
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
#CMD ["/usr/local/bin/docker-cmd.sh"]
