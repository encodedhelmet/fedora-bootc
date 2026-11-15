ARG FEDORA_MAJOR_VERSION=45

FROM quay.io/fedora/fedora-silverblue:${FEDORA_MAJOR_VERSION}

COPY repos/brave-browser.repo /etc/yum.repos.d/
COPY repos/google-chrome.repo /etc/yum.repos.d/
COPY repos/mullvad.repo /etc/yum.repos.d/

RUN rm /opt && \
    mkdir /opt \
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
