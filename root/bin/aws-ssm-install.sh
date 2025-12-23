#!/bin/bash
set -eu

ARCH=$(dpkg --print-architecture)

cd /root

tmpdir=$(mktemp -d /tmp/devops-install-aws-ssm.XXXXXXX)
cd "${tmpdir}"

wget -O ssm.deb "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_${ARCH}/session-manager-plugin.deb"

dpkg -i ssm.deb

cd /root
rm -rf "${tmpdir}"

exit 0
