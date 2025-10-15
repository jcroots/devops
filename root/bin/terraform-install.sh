#!/bin/bash
set -eux

ARCH=$(dpkg --print-architecture)

cd /root

wget -O terraform.zip \
    "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_${ARCH}.zip"

unzip terraform.zip

install -o root -g root -m 0755 ./terraform /usr/local/bin/terraform

terraform -install-autocomplete

exit 0
