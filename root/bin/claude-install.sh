#!/bin/bash
set -eux

install -v -d -m 0755 /usr/local/npm

cd /usr/local/npm

npm install @anthropic-ai/claude-code

ln -vsf /usr/local/npm/node_modules/.bin/claude /usr/local/bin/claude

exit 0
