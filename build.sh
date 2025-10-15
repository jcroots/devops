#!/bin/sh
set -eu

NAME=${1:?'container name?'}

exec docker build --rm \
	-t "jcroots/devops-${NAME}" \
    -f "./${NAME}/Dockerfile" .
