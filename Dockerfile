FROM ghcr.io/bxnlabs/containers/base:20250816.1_1402fa7@sha256:305368d5a978f8c0f00c572ded2e5491ee11e421b901634d68ad596d6370a14f AS base


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
