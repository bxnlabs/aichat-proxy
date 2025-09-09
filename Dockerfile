FROM ghcr.io/bxnlabs/containers/base:20250909.1_06899fc@sha256:4d96e4fdb34e9c940185d012d77887047ce827994cc3a4aa7d3690e0a4a77fd8 AS base


FROM base AS build

ARG TARGETPLATFORM

# renovate: datasource=github-releases packageName=sigoden/aichat versioning=semver
ARG AICHAT_VERSION=v0.30.0

RUN apt-get update && apt-get install curl

WORKDIR /build

RUN if [ "${TARGETPLATFORM}" = "linux/arm64" ]; then \
    curl -L https://github.com/sigoden/aichat/releases/download/${AICHAT_VERSION}/aichat-${AICHAT_VERSION}-aarch64-unknown-linux-musl.tar.gz | tar xz -C /build; \
    elif [ "${TARGETPLATFORM}" = "linux/amd64" ]; then \
    curl -L https://github.com/sigoden/aichat/releases/download/${AICHAT_VERSION}/aichat-${AICHAT_VERSION}-x86_64-unknown-linux-musl.tar.gz | tar xz -C /build; \
    else \
    echo "Unsupported platform: ${TARGETPLATFORM}" && exit 1; \
    fi


FROM base

ENV AICHAT_CONFIG_DIR=/etc/aichat

COPY --from=build /build/aichat ${BXN_HOME}/bin/aichat

# Configuration
COPY ./config.yaml /etc/aichat/

USER nonroot
