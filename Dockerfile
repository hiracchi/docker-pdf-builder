FROM ubuntu:16.04
MAINTAINER Toshiyuki HIRANO <hiracchi@gmail.com>

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/hiracchi/docker-pdf-builder" \
      org.label-schema.version=$VERSION

ARG PDF_HOME="/opt/ProteinDF"
ARG WORKDIR="/work"

ARG PDF_GRP=pdf
ARG PDF_GRPID=56670
ARG PDF_USER=pdf
ARG PDF_USERID=56670

# packages =============================================================
RUN apt-get update \
  && apt-get install -y \
  tcsh zsh \
  build-essential ca-certificates \
  git automake autoconf libtool cmake \
  libopenblas-dev libatlas-dev \
  liblapack-dev liblapacke-dev \
  openmpi-bin libopenmpi-dev \
  libblacs-mpi-dev libscalapack-mpi-dev \
  clinfo opencl-headers libclc-dev mesa-opencl-icd=11.2.0-1ubuntu2 \
  libclblas-dev \
  \
  hdf5-tools \
  libhdf5-dev \
  libhdf5-openmpi-dev \
  \
  vim emacs less \
  \
  python3-dev python3-numpy python3-scipy python3-pandas \
  python3-matplotlib \
  python3-yaml python3-msgpack \
  python3-jinja2 \
  python3-sklearn-lib \
  python3-requests python3-bs4 \
  python3-h5py python3-hdf5storage \
  && apt-get clean && apt-get autoclean \
  && rm -rf /var/lib/apt/lists/* \
  && update-alternatives --config csh


# building env for ProteinDF
ENV PDF_HOME="${PDF_HOME}" PATH="${PATH}:${PDF_HOME}/bin" PYTHONPATH="${PDF_HOME}/lib/python3.5/site-packages"
ENV WORKDIR="${WORKDIR}"
RUN mkdir -p ${PDF_HOME} ${WORKDIR}

RUN groupadd -g ${PDF_GRPID} ${PDF_GRP} \
  && useradd -u ${PDF_USERID} -g ${PDF_GRP} -d /home/${PDF_USER} -s /sbin/nologin ${PDF_USER} \
  && mkdir -p /home/${PDF_USER} \
  && chown -R ${PDF_USER}:${PDF_GRP} /home/${PDF_USER} \
  && chown -R ${PDF_USER}:${PDF_GRP} ${PDF_HOME} \
  && chown -R ${PDF_USER}:${PDF_GRP} ${WORKDIR}

COPY pdf-*.sh /usr/local/bin/

# entrypoint
COPY docker-entrypoint.sh docker-cmd.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/docker-cmd.sh"]

#`USER ${PDF_USER}
WORKDIR ${WORKDIR}
VOLUME ["${PDF_HOME}"]
