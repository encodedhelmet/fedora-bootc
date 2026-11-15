ARG FEDORA_MAJOR_VERSION=45

FROM quay.io/fedora/fedora-silverblue:${FEDORA_MAJOR_VERSION}

COPY repos/brave-browser.repo /etc/yum.repos.d/
COPY repos/google-chrome.repo /etc/yum.repos.d/
COPY repos/mullvad.repo /etc/yum.repos.d/
RUN dnf copr enable -y bieszczaders/kernel-cachyos && \
    dnf install -y \
        kernel-cachyos \
        kernel-cachyos-devel-matched && \
    dnf remove -y \
        kernel \
        kernel-core \
        kernel-modules \
        kernel-modules-core \
        kernel-modules-extra && \
    dnf clean all

RUN dnf install -y \
        https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && \
    dnf clean all

RUN sed -i "/^OSTREE_VERSION='/d" /etc/os-release && \
    dnf install -y \
        akmod-nvidia \
        xorg-x11-drv-nvidia-cuda && \
    dnf clean all && \
    akmods --force --kernels $(ls /usr/lib/modules)

COPY files/00-nvidia.toml /usr/lib/bootc/kargs.d/

RUN rm /opt && \
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
    dnf clean all

RUN systemctl enable \
        mullvad-daemon \
        mullvad-early-boot-blocking

RUN bootc container lint
