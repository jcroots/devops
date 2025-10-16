#!/bin/sh
set -eu

NAME=${1:?'container name?'}

exec docker run -it --rm -u devops \
    --name "devops-${NAME}" \
    --hostname "${NAME}.local" \
    -e "TERM=${TERM}" \
    "jcroots/devops-${NAME}"
