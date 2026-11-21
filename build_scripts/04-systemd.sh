#!/usr/bin/env bash
set -eoux pipefail

systemctl enable \
    mullvad-daemon \
    mullvad-early-boot-blocking
