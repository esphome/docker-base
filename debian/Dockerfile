FROM python:3.12-slim-bookworm AS base

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN \
  set -x \
  && apt update \
  && apt install -y --no-install-recommends \
      iputils-ping=3:20221126-1+deb12u1 \
      git=1:2.39.5-0+deb12u2 \
      curl=7.88.1-10+deb12u12 \
      openssh-client=1:9.2p1-2+deb12u5 \
      libcairo2=1.16.0-7 \
      libmagic1=1:5.44-3 \
      patch=2.7.6-7 \
  && apt purge -y --auto-remove \
  && rm -rf \
      /tmp/* \
      /var/{cache,log}/* \
      /var/lib/apt/lists/* \
      /usr/src/*

ENV UV_SYSTEM_PYTHON=true
ENV PIP_ROOT_USER_ACTION=ignore


FROM base AS ha-addon

RUN \
    set -x \
    && apt update \
    && apt install -y --no-install-recommends \
        nginx-light=1.22.1-9+deb12u1 \
        jq=1.6-2.1 \
        xz-utils=5.4.1-0.2 \
    && rm -rf \
        /tmp/* \
        /var/{cache,log}/* \
        /var/lib/apt/lists/* \
        /usr/src/*

ARG \
    BASHIO_VERSION=0.16.3 \
    TEMPIO_VERSION=2024.11.2 \
    S6_OVERLAY_VERSION=3.2.0.2

WORKDIR /usr/src

ARG TARGETARCH
ARG TARGETVARIANT

RUN \
    set -x \
    && if [ "${TARGETARCH}${TARGETVARIANT}" = "amd64" ]; then \
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
