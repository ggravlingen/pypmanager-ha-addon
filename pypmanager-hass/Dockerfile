# docker build --no-cache --platform linux/aarch64 --build-arg BUILD_FROM=ghcr.io/home-assistant/aarch64-base-debian:bookworm -t local/amd64-addon-pypmanager-hass:1.0.0 .
ARG BUILD_FROM
###############################################################################
#  Build stage – React front-end
###############################################################################
ARG APP_VERSION=2025.7.1
FROM node:20-alpine AS frontend

ENV FRONTEND_FOLDER=/tmp/pypmanager-frontend

RUN apk add --no-cache git

# clone only the needed branch
ARG APP_VERSION
ENV FRONTEND_SRC=/tmp/pypmanager
RUN git clone --depth 1 --branch "${APP_VERSION}" \
      https://github.com/ggravlingen/pypmanager.git  "${FRONTEND_SRC}"

# build the bundle (CRA)
WORKDIR ${FRONTEND_SRC}/frontend
RUN npm install -g corepack && \
    yarn && \
    NODE_ENV=production yarn build-hass-addon

###############################################################################
#  Final stage – Home-Assistant base image
###############################################################################
ARG BUILD_FROM
FROM ${BUILD_FROM}

ARG APP_VERSION

# Based on Home Assistant Docker base image
# https://github.com/home-assistant/docker-base/blob/master/python/3.13/Dockerfile
ENV PYTHON_VERSION=3.13.5 \
    PIP_VERSION=25.1.1 \
    CERT_IDENTITY=thomas@python.org \
    CERT_OIDC_ISSUER=https://accounts.google.com \
    ROOT_FOLDER=/app

# ensure local python is preferred over distribution python
ENV PATH=/usr/local/bin:$PATH

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install Python 3.13
# Install Python 3.13 from source (Debian-based)
RUN set -ex \
    && export PYTHON_VERSION=${PYTHON_VERSION} \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        wget \
        build-essential \
        libssl-dev \
        zlib1g-dev \
        libncurses5-dev \
        libncursesw5-dev \
        libreadline-dev \
        libsqlite3-dev \
        libgdbm-dev \
        libdb5.3-dev \
        libbz2-dev \
        libexpat1-dev \
        liblzma-dev \
        tk-dev \
        libffi-dev \
        uuid-dev \
        curl \
        ca-certificates \
        git \
    && wget "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tgz" \
    && tar -xzf Python-$PYTHON_VERSION.tgz -C /usr/src/ \
    && cd /usr/src/Python-$PYTHON_VERSION \
    && ./configure --enable-optimizations --with-ensurepip=install \
    && make -j"$(nproc)" \
    && make altinstall \
    && cd / \
    && rm -rf /usr/src/Python-$PYTHON_VERSION* \
    && rm -f Python-$PYTHON_VERSION.tgz \
    && apt-get purge -y --auto-remove \
        wget \
        build-essential \
        libssl-dev \
        zlib1g-dev \
        libncurses5-dev \
        libncursesw5-dev \
        libreadline-dev \
        libsqlite3-dev \
        libgdbm-dev \
        libdb5.3-dev \
        libbz2-dev \
        libexpat1-dev \
        liblzma-dev \
        tk-dev \
        libffi-dev \
        uuid-dev \
    && rm -rf /var/lib/apt/lists/*

# make some useful symlinks that are expected to exist
RUN cd /usr/local/bin \
    && ln -s idle3 idle \
    && ln -s pydoc3 pydoc \
    && ln -s python3.13 python3 \
    && ln -s python3 python \
    && ln -s python3.13-config python3-config \
    && ln -s python3-config python-config

# Install pip
RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends libsqlite3-dev openssl; \
    curl -L -o get-pip.py 'https://bootstrap.pypa.io/get-pip.py'; \
    python3.13 get-pip.py \
        --disable-pip-version-check \
        --no-cache-dir \
        pip==${PIP_VERSION}; \
    pip --version; \
    rm -f get-pip.py; \
    # apt-get purge -y --auto-remove openssl; \
    rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# Backend code
# -----------------------------------------------------------------------------
RUN mkdir -p ${ROOT_FOLDER} && \
    git clone --single-branch --branch "$APP_VERSION" https://github.com/ggravlingen/pypmanager.git ${ROOT_FOLDER} && \
    cd ${ROOT_FOLDER} && \
    pip3 install --no-cache-dir .

# -----------------------------------------------------------------------------
# Static front-end assets
# -----------------------------------------------------------------------------
RUN mkdir -p ${ROOT_FOLDER}/frontend/static
COPY --from=frontend /tmp/pypmanager/frontend/static/ \
     ${ROOT_FOLDER}/frontend/static/
COPY --from=frontend /tmp/pypmanager/frontend/templates/index.html \
     ${ROOT_FOLDER}/frontend/templates/index.html

WORKDIR ${ROOT_FOLDER}
RUN echo "hell2o2"
# -----------------------------------------------------------------------------
# Copy S6 / run script / apparmor / anything else from rootfs
# -----------------------------------------------------------------------------
COPY rootfs /
