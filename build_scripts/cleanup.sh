#!/usr/bin/env bash
set -eoux pipefail

dnf clean all
rm -rf \
    /boot/* \
    /run/dnf \
    /var/cache/* \
    /var/lib/dnf \
    /var/lib/rpm-state \
    /var/log/*
