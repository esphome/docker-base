FROM python:3.12-slim-bookworm AS base

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN \
  set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
      iputils-ping=3:20221126-1 \
      git=1:2.39.5-0+deb12u1 \
      curl=7.88.1-10+deb12u7 \
      openssh-client=1:9.2p1-2+deb12u3 \
      libcairo2=1.16.0-7 \
      libmagic1=1:5.44-3 \
      patch=2.7.6-7 \
  && apt-get purge -y --auto-remove \
  && rm -rf \
      /tmp/* \
      /var/{cache,log}/* \
      /var/lib/apt/lists/* \
      /usr/src/*

FROM base AS base-amd64
FROM base AS base-arm64
FROM base AS base-armv7

ENV UV_EXTRA_INDEX_URL=https://www.piwheels.org/simple

RUN \
  set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
      build-essential=12.9 \
      python3-dev=3.11.2-1+b1 \
      zlib1g-dev=1:1.2.13.dfsg-1 \
      libjpeg-dev=1:2.1.5-2 \
      libfreetype-dev=2.12.1+dfsg-5+deb12u3 \
      libssl-dev=3.0.14-1~deb12u2 \
      libffi-dev=3.4.4-1 \
      libopenjp2-7=2.5.0-2 \
      libtiff6=4.5.0-6+deb12u1 \
      cargo=0.66.0+ds1-1 \
      pkg-config=1.8.1-1 \
      gcc-arm-linux-gnueabihf=4:12.2.0-3 \
  && rm -rf \
      /tmp/* \
      /var/{cache,log}/* \
      /var/lib/apt/lists/* \
      /usr/src/*

RUN ln -s /lib/arm-linux-gnueabihf/ld-linux-armhf.so.3 /lib/ld-linux.so.3

ARG TARGETARCH
ARG TARGETVARIANT

FROM base-${TARGETARCH}${TARGETVARIANT} AS docker

ENV UV_SYSTEM_PYTHON=true
ENV PIP_ROOT_USER_ACTION=ignore

RUN pip install uv==0.2.21

FROM docker AS ha-addon

RUN \
    set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        nginx-light=1.22.1-9 \
        jq=1.6-2.1 \
        xz-utils=5.4.1-0.2 \
    && rm -rf \
        /tmp/* \
        /var/{cache,log}/* \
        /var/lib/apt/lists/* \
        /usr/src/*

ARG \
    BASHIO_VERSION=0.16.2 \
    TEMPIO_VERSION=2021.09.0 \
    S6_OVERLAY_VERSION=3.2.0.0

WORKDIR /usr/src

ARG TARGETARCH
ARG TARGETVARIANT

RUN \
    set -x \
    && if [ "${TARGETARCH}${TARGETVARIANT}" = "armv7" ]; then \
            export S6_ARCH="arm"; \
            export TEMPIO_ARCH="armv7"; \
        elif [ "${TARGETARCH}${TARGETVARIANT}" = "amd64" ]; then \
            export S6_ARCH="x86_64"; \
            export TEMPIO_ARCH="amd64"; \
        elif [ "${TARGETARCH}${TARGETVARIANT}" = "arm64" ]; then \
            export S6_ARCH="aarch64"; \
            export TEMPIO_ARCH="aarch64"; \
        fi \
    \
    && curl -L -f -s "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}.tar.xz" \
        | tar Jxvf - -C / \
    && curl -L -f -s "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" \
        | tar Jxvf - -C / \
    && curl -L -f -s "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-arch.tar.xz" \
        | tar Jxvf - -C / \
    && curl -L -f -s "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-noarch.tar.xz" \
        | tar Jxvf - -C / \
    && mkdir -p /etc/fix-attrs.d \
    && mkdir -p /etc/services.d \
    \
    && curl -L -f -s -o /usr/bin/tempio \
        "https://github.com/home-assistant/tempio/releases/download/${TEMPIO_VERSION}/tempio_${TEMPIO_ARCH}" \
    && chmod a+x /usr/bin/tempio \
    \
    && mkdir -p /usr/src/bashio \
    && curl -L -f -s "https://github.com/hassio-addons/bashio/archive/v${BASHIO_VERSION}.tar.gz" \
        | tar -xzf - --strip 1 -C /usr/src/bashio \
    && mv /usr/src/bashio/lib /usr/lib/bashio \
    && ln -s /usr/lib/bashio/bashio /usr/bin/bashio \
    \
    && rm -rf /usr/src/*

WORKDIR /root
ENTRYPOINT ["/init"]
