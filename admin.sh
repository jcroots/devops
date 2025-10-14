#!/bin/sh
set -eu

NAME=${1:?'container name?'}

exec docker run -it --rm -u nobody \
    --name "devops-${NAME}" \
    --hostname "devops-${NAME}.local" \
    "jcroots/devops-${NAME}"
