#!/bin/bash
# SSH Device Connect
# This script exists to run on the SSH Server receiving tunnels from devices. It allows you to
# connect to the device's SSH tunnel.

REMOTE_PRIVATE_KEY="/root/data/openssh/keys/automox-remote"
EP_TUNNEL_PORT=43022
EP_USER="root"

ssh \
    ${EP_USER}@localhost \
    -p ${EP_TUNNEL_PORT} \
    -i ${REMOTE_PRIVATE_KEY} \
    -o StrictHostKeyChecking=no
