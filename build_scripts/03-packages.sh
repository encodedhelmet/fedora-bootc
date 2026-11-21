#!/usr/bin/env bash
set -eoux pipefail

rm /opt
mkdir -p /opt
cp /ctx/repos/*.repo /etc/yum.repos.d/
dnf install -y \
    brave-browser \
    distrobox \
    google-chrome-stable \
    mullvad-vpn
dnf remove -y \
    firefox \
    firefox-langpacks \
    gnome-tour \
    malcontent-control \
    toolbox \
    yelp
