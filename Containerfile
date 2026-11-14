ARG FEDORA_MAJOR_VERSION=45

FROM quay.io/fedora/fedora-silverblue:${FEDORA_MAJOR_VERSION}

COPY repos/brave-browser.repo /etc/yum.repos.d/brave-browser.repo

RUN bootc container lint
