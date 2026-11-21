#!/usr/bin/env bash
set -eoux pipefail

dnf install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
dnf install -y \
    /rpms/*.rpm \
    xorg-x11-drv-nvidia-cuda
mkdir -p /usr/lib/bootc/kargs.d/
cp /ctx/files/00-nvidia.toml /usr/lib/bootc/kargs.d/
