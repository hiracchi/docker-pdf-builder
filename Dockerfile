FROM ubuntu:16.04
MAINTAINER Toshiyuki HIRANO <hiracchi@gmail.com>

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/hiracchi/docker-pdf-builder" \
      org.label-schema.version=$VERSION

# ARG WORK_USER=docker
ARG PROTEINDF_REPOSITORY="https://github.com/ProteinDF/ProteinDF.git"

# packages =============================================================
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  tcsh zsh \
  build-essential ca-certificates \
  git automake autoconf libtool cmake \
  libopenblas-dev libatlas-dev \
  liblapack-dev liblapacke-dev \
  openmpi-bin libopenmpi-dev \
  libblacs-mpi-dev libscalapack-mpi-dev \
  clinfo opencl-headers libclc-dev mesa-opencl-icd \
  libclblas-dev \
  \
  vim emacs less \
  && apt-get clean && apt-get autoclean \
  && rm -rf /var/lib/apt/lists/* \
  && update-alternatives --config csh


# build ProteinDF
COPY build-pdf.sh /usr/local/bin/


# entrypoint
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/local/bin/build-pdf.sh"]



