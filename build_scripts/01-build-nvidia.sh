#!/usr/bin/env bash
set -eoux pipefail

dnf install -y \
    dnf5-plugins \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
dnf copr enable -y \
    bieszczaders/kernel-cachyos
dnf install -y \
    akmods \
    akmod-nvidia \
    kernel-cachyos \
    kernel-cachyos-devel-matched
akmods --force --kernels $(rpm -q kernel-cachyos-devel-matched --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')
mkdir -p /rpms
cp /var/cache/akmods/nvidia/*.rpm /rpms/
