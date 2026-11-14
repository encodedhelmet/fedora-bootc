ARG FEDORA_MAJOR_VERSION=45

FROM quay.io/fedora/fedora-silverblue:${FEDORA_MAJOR_VERSION}

COPY repos/brave-browser.repo /etc/yum.repos.d/brave-browser.repo
COPY repos/mullvad.repo /etc/yum.repos.d/mullvad.repo

RUN dnf install -y \
    brave-browser

RUN bootc container lint
