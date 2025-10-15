#!/bin/bash
set -eux

TF_VERSION='1.13.3'

ARCH=$(dpkg --print-architecture)

cd /root

tmpdir=$(mktemp -d /tmp/devops-install-terraform.XXXXXXX)
cd "${tmpdir}"

wget -O terraform.zip \
    "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_${ARCH}.zip"

unzip terraform.zip

install -o root -g root -m 0755 ./terraform /usr/local/bin/terraform

rm -f terraform.zip terraform

terraform -install-autocomplete

cd /root
rm -rf "${tmpdir}"

exit 0
