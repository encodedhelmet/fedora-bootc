ARG BASE_IMAGE=quay.io/fedora/fedora-silverblue
ARG BUILD_IMAGE=quay.io/fedora/fedora-bootc
ARG FEDORA_MAJOR_VERSION=45

FROM scratch AS ctx
copy /build_scripts /build_scripts

FROM ${BUILD_IMAGE}:${FEDORA_MAJOR_VERSION} AS builder

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/build_scripts/01-build-nvidia.sh

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION}

COPY repos/brave-browser.repo /etc/yum.repos.d/
COPY repos/google-chrome.repo /etc/yum.repos.d/
COPY repos/mullvad.repo /etc/yum.repos.d/
COPY files/00-nvidia.toml /usr/lib/bootc/kargs.d/

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=bind,from=builder,src=/rpms,destination=/rpms \
    /ctx/build_scripts/02-install-nvidia.sh && \
    rm /opt && \
    mkdir /opt && \
    dnf install -y \
        brave-browser \
        distrobox \
        google-chrome-stable \
        mullvad-vpn && \
    dnf remove -y \
        firefox \
        firefox-langpacks \
        gnome-tour \
        malcontent-control \
        toolbox \
        yelp && \
    systemctl enable \
        mullvad-daemon \
        mullvad-early-boot-blocking && \
    dnf clean all && \
    rm -rf \
        /boot/* \
        /run/akmods \
        /run/dnf \
        /var/cache/* \
        /var/lib/dnf \
        /var/lib/rpm-state \
        /var/log/* && \
    bootc container lint
