FROM hiracchi/ubuntu-ja:latest

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

ENV LANG="ja_JP.UTF-8" LANGUAGE="ja_JP:en" LC_ALL="ja_JP.UTF-8" TZ="Asia/Tokyo"
ENV DEBIAN_FRONTEND=noninteractive

ENV PACKAGES="\
  vim \
  build-essential gfortran pkg-config \
  git automake autoconf libtool cmake \
  libopenblas-base libopenblas-dev \
  libscalapack-openmpi-dev \
  openmpi-bin openmpi-common \
  libeigen3-dev \
  opencl-headers ocl-icd-opencl-dev libclc-dev mesa-opencl-icd clinfo \
  libboost-all-dev \
  hdf5-tools libhdf5-dev libhdf5-openmpi-dev \
  python3-dev python3-pip python3-setuptools python3-pip python3-wheel \
  python3-numpy python3-scipy python3-scipy python3-pandas \
  python3-xlrd \
  python3-yaml python3-msgpack \
  python3-tqdm \
  python3-requests python3-jinja2 python3-bs4 \
  python3-matplotlib \
  python3-sklearn \
  python3-h5py \
  "

# ======================================================================
# packages 
# ======================================================================
RUN set -x && \
  apt-get update && \
  apt-get install -y ${PACKAGES} && \
  apt-get clean && apt-get autoclean && \
  rm -rf /var/lib/apt/lists/*


WORKDIR /tmp
# =============================================================================
# google-test
# =============================================================================
RUN set -x && \
  git clone --depth 1 "https://github.com/google/googletest.git" && \
  mkdir -p googletest/build && \
  cd googletest/build && \
  cmake .. && \
  make && make install && \
  rm -rf /tmp/googletest

# =============================================================================
# viennacl-dev
# =============================================================================
# RUN set -x && \
#   curl -L -o ViennaCL-1.7.1.tar.gz "http://sourceforge.net/projects/viennacl/files/1.7.x/ViennaCL-1.7.1.tar.gz/download" && \
#   tar zxvf ViennaCL-1.7.1.tar.gz && \
#   cd /tmp/ViennaCL-1.7.1/build && \
#   cmake .. && \
#   make && make install

RUN set -x && \
  git clone --depth 1 "https://github.com/viennacl/viennacl-dev.git" && \
  mkdir -p viennacl-dev/build && \
  cd viennacl-dev/build && \
  cmake .. && \
  make && make install && \
  rm -rf /tmp/viennacl-dev

# -----------------------------------------------------------------------------
# setup dirs
# -----------------------------------------------------------------------------
# RUN set -x \
#   && mkdir -p "${WORKDIR}" \
#   && chmod 777 "${WORKDIR}" \
#   && mv /root/.jupyter "${WORKDIR}" \
#   && ln -s "${WORKDIR}/.jupyter" /root/.jupyter


# =============================================================================
# entrypoint
# =============================================================================
COPY scripts/* /usr/local/bin/

WORKDIR ${WORKDIR}
ENV PDF_HOME="${PDF_HOME}" PATH="${PATH}:${PDF_HOME}/bin"
ENV WORKDIR="${WORKDIR}"
VOLUME ${WORKDIR}

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/bin/tail", "-f", "/dev/null"]
