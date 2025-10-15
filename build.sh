#!/bin/sh
set -eu

NAME=${1:?'container name?'}

exec docker build --rm \
	-t "ghcr.io/jcroots/devops/${NAME}" \
    -f "./${NAME}/Dockerfile" .
