#!/bin/bash
set -eux

CSP_VERSION='2.20.0'

ARCH=$(dpkg --print-architecture)

cd /root

tmpdir=$(mktemp -d /tmp/devops-install-gcloud-sql-proxy.XXXXXXX)
cd "${tmpdir}"

wget -O cloud-sql-proxy.bin \
    "https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v${CSP_VERSION}/cloud-sql-proxy.linux.${ARCH}"

install -o root -g root -m 0755 ./cloud-sql-proxy.bin /usr/local/bin/cloud-sql-proxy

rm -f cloud-sql-proxy.bin

/usr/local/bin/cloud-sql-proxy --version

cd /root
rm -rf "${tmpdir}"

exit 0
