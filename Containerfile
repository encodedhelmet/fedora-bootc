ARG BASE_IMAGE=quay.io/fedora/fedora-silverblue
ARG BUILD_IMAGE=quay.io/fedora/fedora-bootc
ARG FEDORA_MAJOR_VERSION=45

FROM ${BUILD_IMAGE}:${FEDORA_MAJOR_VERSION} AS builder

RUN dnf install -y \
        https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && \
    dnf install -y \
        dnf-plugins-core && \
    dnf copr enable -y \
        bieszczaders/kernel-cachyos && \
    dnf install -y \
        akmods \
        akmod-nvidia \
        kernel-cachyos \
        kernel-cachyos-devel-matched && \
    akmods --force --kernels $(rpm -q kernel-cachyos-devel-matched --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}') && \
    mkdir -p /rpms && \
    cp /var/cache/akmods/nvidia/*.rpm /rpms/

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION}

COPY repos/brave-browser.repo /etc/yum.repos.d/
COPY repos/google-chrome.repo /etc/yum.repos.d/
COPY repos/mullvad.repo /etc/yum.repos.d/
COPY files/00-nvidia.toml /usr/lib/bootc/kargs.d/
RUN --mount=type=bind,from=builder,src=/rpms,destination=/rpms \
    dnf install -y \
        https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && \
    dnf copr enable -y \
        bieszczaders/kernel-cachyos && \
    dnf install -y \
        kernel-cachyos && \
    dnf remove -y \
        kernel \
        kernel-core \
        kernel-modules \
        kernel-modules-core \
        kernel-modules-extra && \
    dnf install -y \
        /rpms/*.rpm \
        xorg-x11-drv-nvidia-cuda && \
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
    rm -rf \
        /boot/* \
        /run/akmods \
        /run/dnf \
        /var/cache/* \
        /var/lib/dnf \
        /var/lib/rpm-state \
        /var/log/* && \
    dnf clean all && \
    bootc container lint
