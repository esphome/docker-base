FROM python:3.11-slim AS base

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN \
  set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
      iputils-ping=3:20221126-1 \
      git=1:2.39.2-1.1 \
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
ENV PIP_EXTRA_INDEX_URL=https://www.piwheels.org/simple

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

FROM base-${TARGETARCH}${TARGETVARIANT} AS final

ENV UV_SYSTEM_PYTHON=true

RUN pip install uv==0.2.21

RUN ls -al

