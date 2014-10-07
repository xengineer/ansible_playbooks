#!/usr/bin/env bash

apt-get install -y curl
curl -L http://toolbelt.treasuredata.com/sh/install-ubuntu-precise.sh | sh

mkdir /var/log/td-agent/tmp/
chown td-agent. /var/log/td-agent/tmp