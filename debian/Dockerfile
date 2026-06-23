FROM python:3.13-slim-trixie AS base

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN \
  set -x \
  && apt update \
  && apt install -y --no-install-recommends \
      iputils-ping=3:20240905-3 \
      git=1:2.47.3-0+deb13u1 \
      curl=8.14.1-2+deb13u3 \
      openssh-client=1:10.0p1-7+deb13u4 \
      libcairo2=1.18.4-1+b1 \
      libmagic1t64=1:5.46-5 \
      patch=2.8-2 \
      build-essential=12.12 \
      libusb-1.0-0=2:1.0.28-1 \
      ccache=4.11.2-2 \
  && apt purge -y --auto-remove \
  && rm -rf \
      /tmp/* \
      /var/{cache,log}/* \
      /var/lib/apt/lists/* \
      /usr/src/*

RUN usermod -U root -a -G staff

ENV UV_SYSTEM_PYTHON=true
ENV PIP_ROOT_USER_ACTION=ignore


FROM base AS ha-addon

RUN \
    set -x \
    && apt update \
    && apt install -y --no-install-recommends \
        jq=1.7.1-6+deb13u2 \
        xz-utils=5.8.1-1 \
    && rm -rf \
        /tmp/* \
        /var/{cache,log}/* \
        /var/lib/apt/lists/* \
        /usr/src/*

# renovate: datasource=github-releases depName=hassio-addons/bashio
ARG BASHIO_VERSION=0.17.5
# renovate: datasource=github-releases depName=home-assistant/tempio versioning=loose
ARG TEMPIO_VERSION=2024.11.2
# renovate: datasource=github-releases depName=just-containers/s6-overlay versioning=loose
ARG S6_OVERLAY_VERSION=3.2.2.0

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
