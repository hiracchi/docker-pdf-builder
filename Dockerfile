FROM hiracchi/ubuntu-ja:18.04.1

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/hiracchi/docker-pdf-builder" \
      org.label-schema.version=$VERSION \
      maintainer="Toshiyuki Hirano <hiracchi@gmail.com>"

ARG NGLVIEW_VER=1.1.7
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
  && apt-get clean && apt-get autoclean \
  && rm -rf /var/lib/apt/lists/*

# =============================================================================
# pip package 
# =============================================================================
RUN set -x \
  && pip3 install --no-cache-dir \
    msgpack-python pyyaml \
    numpy scipy sympy pandas xlrd xlwt \
    matplotlib  bokeh \
    scikit-learn \
    h5py tqdm \
    requests beautifulsoup4 \
    jinja2 \
    jupyter \
    jupyter_contrib_nbextensions \
    jupyter_nbextensions_configurator \
    ipywidgets \
    nglview==${NGLVIEW_VER}

RUN set -x \
  && jupyter contrib nbextension install \
  && jupyter nbextensions_configurator enable \
  && jupyter nbextension enable widgetsnbextension \
  && jupyter-nbextension enable nglview 


# =============================================================================
# viennacl-dev 
# =============================================================================
RUN set -x \
  && cd /tmp \
  && git clone "https://github.com/viennacl/viennacl-dev.git" \
  && mkdir -p /tmp/viennacl-dev/build \
  && cd /tmp/viennacl-dev/build \
  && cmake .. \
  && make \
  && make install


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
RUN set -x \
  && mkdir -p "${WORKDIR}" \
  && chmod 777 "${WORKDIR}" \
  && mv /root/.jupyter "${WORKDIR}" \
  && ln -s "${WORKDIR}/.jupyter" /root/.jupyter 


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

# ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/local/bin/run-jupyter.sh"]
