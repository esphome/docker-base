FROM python:3.13-alpine3.22 AS base

ENV \
    UV_EXTRA_INDEX_URL=https://wheels.home-assistant.io/musllinux-index/

RUN \
  set -x \
  && apk add --no-cache \
      bash=5.2.37-r0 \
      git=2.49.1-r0 \
      curl=8.14.1-r2 \
      openssh-client-default=10.0_p1-r10 \
      cairo=1.18.4-r0 \
      libmagic=5.46-r2 \
      patch=2.8-r0 \
      cmake=3.31.7-r1 \
      samurai=1.2-r7

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV UV_SYSTEM_PYTHON=true
ENV UV_INDEX_STRATEGY=unsafe-best-match
ENV PIP_ROOT_USER_ACTION=ignore

FROM base AS ha-addon

RUN \
    set -x \
    && apk add --no-cache \
        nginx=1.28.3-r0 \
        jq=1.8.1-r0 \
        xz=5.8.1-r0

ARG \
    BASHIO_VERSION=0.17.5 \
    TEMPIO_VERSION=2024.11.2 \
    S6_OVERLAY_VERSION=3.2.2.0

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
