ARG BASE_IMAGE=quay.io/fedora/fedora-cosmic-atomic
ARG BUILD_IMAGE=quay.io/fedora/fedora-bootc
ARG FEDORA_MAJOR_VERSION=45

FROM scratch AS ctx
COPY build_scripts /build_scripts
COPY repos /repos
COPY files /files

FROM ${BUILD_IMAGE}:${FEDORA_MAJOR_VERSION} AS builder

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/build_scripts/01-build-nvidia.sh

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION}

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=bind,from=builder,src=/rpms,destination=/rpms \
    /ctx/build_scripts/02-install-nvidia.sh && \
    /ctx/build_scripts/cleanup.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/build_scripts/03-packages.sh && \
    /ctx/build_scripts/cleanup.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/build_scripts/04-systemd.sh

RUN bootc container lint
