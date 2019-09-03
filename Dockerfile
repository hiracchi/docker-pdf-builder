FROM ubuntu:18.04

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

RUN set -x \
  && apt-get update \
  && apt-get install -y \
     apt-utils sudo wget gnupg locales tzdata \
  && locale-gen ja_JP.UTF-8 \
  && update-locale LANG=ja_JP.UTF-8 \
  && apt-get install -y tzdata \
  && echo "${TZ}" > /etc/timezone \
  && mv /etc/localtime /etc/localtime.orig \
  && ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
  && dpkg-reconfigure -f noninteractive tzdata \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# packages =============================================================
RUN set -x \
  && apt-get update \
  && apt-get install -y \
    vim \
    build-essential gfortran \
    pkg-config ca-certificates \
    git automake autoconf libtool cmake \
    libopenblas-base libopenblas-dev \
    libscalapack-openmpi-dev \
    openmpi-bin openmpi-common \
    \
    libeigen3-dev \
    \
    opencl-headers libclc-dev mesa-opencl-icd clinfo \
    \
    libboost-all-dev \
    hdf5-tools \
    libhdf5-dev \
    libhdf5-openmpi-dev \
    \
    python3-dev python3-pip python3-setuptools python3-pip python3-wheel \
    python3-numpy python3-scipy python3-scipy python3-pandas \
    python3-xlrd \
    python3-yaml python3-msgpack \
    python3-tqdm \
    python3-requests python3-jinja2 python3-bs4 \
    python3-matplotlib \
    python3-sklearn \
    python3-h5py \
  && apt-get clean && apt-get autoclean \
  && rm -rf /var/lib/apt/lists/*

# =============================================================================
# pip package
# =============================================================================
 RUN set -x \
   && pip3 install --no-cache-dir \
    jupyter \
    jupyter_contrib_nbextensions \
    jupyter_nbextensions_configurator \
    ipywidgets \
    pytraj \
    nglview

# RUN set -x \
#   && pip3 install --no-cache-dir \
#     msgpack-python pyyaml \
#     numpy scipy sympy pandas xlrd xlwt \
#     matplotlib  bokeh \
#     scikit-learn \
#     h5py tqdm \
#     requests beautifulsoup4 \
#     jinja2 \

# RUN set -x \
#   && jupyter contrib nbextension install \
#   && jupyter nbextensions_configurator enable \
#   && jupyter nbextension enable widgetsnbextension \
#   && jupyter-nbextension enable nglview


# =============================================================================
# viennacl-dev
# =============================================================================
# RUN set -x \
#   && cd /tmp \
#   && curl -L -o ViennaCL-1.7.1.tar.gz "http://sourceforge.net/projects/viennacl/files/1.7.x/ViennaCL-1.7.1.tar.gz/download" \
#   && tar zxvf ViennaCL-1.7.1.tar.gz \
#   && cd /tmp/ViennaCL-1.7.1/build \
#   && cmake .. \
#   && make\
#   && make install

# RUN set -x \
#   && cd /tmp \
#   && git clone "https://github.com/viennacl/viennacl-dev.git" \
#   && mkdir -p /tmp/viennacl-dev/build \
#   && cd /tmp/viennacl-dev/build \
#   && cmake .. \
#   && make \
#   && make install


# =============================================================================
# google-test
# =============================================================================
RUN set -x \
  && cd /tmp \
  && git clone "https://github.com/google/googletest.git" \
  && mkdir -p /tmp/googletest/build \
  && cd /tmp/googletest/build \
  && cmake .. \
  && make \
  && make install \
  && rm -rf /tmp/googletest


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
COPY docker-*.sh pdf-*.sh env2cmake.py run-*.sh /usr/local/bin/
RUN set -x \
  && chmod +x /usr/local/bin/*.sh /usr/local/bin/*.py

WORKDIR ${WORKDIR}
ENV PDF_HOME="${PDF_HOME}" PATH="${PATH}:${PDF_HOME}/bin"
ENV WORKDIR="${WORKDIR}"
VOLUME ${WORKDIR}

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/bin/tail", "-f", "/dev/null"]
# CMD ["/usr/local/bin/run-jupyter.sh"]
