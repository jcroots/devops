#!/bin/bash
set -eu

check_gcloud_auth() {
    if gcloud auth application-default print-access-token >/dev/null; then
        return 0
    else
        return 1
    fi
}

if ! check_gcloud_auth; then
    gcloud auth application-default login --no-launch-browser
fi

exec /bin/bash -i -l
