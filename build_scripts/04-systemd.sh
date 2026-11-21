#!/usr/bin/env bash
set -eoux pipefail

systemctl enable \
    libvirtd \
    mullvad-daemon \
    mullvad-early-boot-blocking
