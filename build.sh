#!/bin/sh
set -eu

NAME=${1:?'container name?'}

exec docker build --rm --pull \
    -t "jcroots/devops-${NAME}" \
    -f "./${NAME}/Dockerfile" .
