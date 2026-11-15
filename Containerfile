ARG FEDORA_MAJOR_VERSION=45

FROM quay.io/fedora/fedora-silverblue:${FEDORA_MAJOR_VERSION}

COPY repos/brave-browser.repo /etc/yum.repos.d/
COPY repos/google-chrome.repo /etc/yum.repos.d/
COPY repos/mullvad.repo /etc/yum.repos.d/
RUN dnf install -y \
        https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && \
    dnf clean all

RUN sed -i "/^OSTREE_VERSION='/d" /etc/os-release && \
    dnf install -y \
        akmod-nvidia \
        xorg-x11-drv-nvidia-cuda && \
    dnf clean all && \
    akmods --force --kernels $(rpm -q kernel-devel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')

COPY <<EOF /usr/lib/bootc/kargs.d/00-nvidia.toml
kargs = [
    "rd.driver.blacklist=nouveau,nova_core",
    "modprobe.blacklist=nouveau,nova_core"
]
EOF

RUN dnf install -y \
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
