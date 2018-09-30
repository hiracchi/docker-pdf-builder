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

ARG PDF_GRP=pdf
ARG PDF_GRPID=56670
ARG PDF_USER=pdf
ARG PDF_USERID=56670

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

#  python-dev python-pip \
#  curl openssl libssl-dev libbz2-dev libreadline-dev libsqlite3-dev \

# google-test ==========================================================
RUN cd /tmp \
  && git clone "https://github.com/google/googletest.git" \
  && mkdir -p /tmp/googletest/build \
  && cd /tmp/googletest/build \
  && cmake .. \
  && make \
  && make install \
  && rm -rf /tmp/googletest

# Python ===============================================================
#RUN set -x \
#  && git clone "git://github.com/yyuu/pyenv.git" .pyenv
#ENV PYENV_ROOT ${HOME}/.pyenv
#ENV PATH ${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:$PATH
#RUN set -x \
#  && pyenv install 2.7.12 \
#  && pyenv install 3.6.4 \
#  && pyenv global 3.6.4
#COPY requires.txt /tmp
#RUN set -x \
#  && apt-get update \
#  && apt-get install -y python-cairo
#RUN set -x \
#  && pip3 install -r /tmp/requires.txt

# entrypoint ===========================================================
USER root
COPY docker-*.sh pdf-*.sh env2cmake.py /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/local/bin/docker-cmd.sh"]

# building env for ProteinDF ===========================================
RUN set -x \
  && groupadd -g ${PDF_GRPID} ${PDF_GRP} \
  && useradd -u ${PDF_USERID} -g ${PDF_GRP} -d /home/${PDF_USER} --create-home -s /bin/bash ${PDF_USER} \
  && mkdir -p /home/${PDF_USER} \
  && mkdir -p ${PDF_HOME} ${WORKDIR} \
  && chown -R ${PDF_USER}:${PDF_GRP} /home/${PDF_USER} \
  && chown -R ${PDF_USER}:${PDF_GRP} ${PDF_HOME} \
  && chown -R ${PDF_USER}:${PDF_GRP} ${WORKDIR}


# account ==============================================================
USER ${PDF_USER}
WORKDIR ${WORKDIR}
ENV PDF_HOME="${PDF_HOME}"

#WORKDIR /home/${PDF_USER}
#ENV HOME /home/${PDF_USER}
#VOLUME ["${PDF_HOME}"]
#ENV PATH="${PATH}:${PDF_HOME}/bin"
#ENV WORKDIR="${WORKDIR}"
