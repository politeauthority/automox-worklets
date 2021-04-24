#!/bin/bash
# Reverse Tunnel - Remediation
set -e

REMOTE_SSH_USER="root"
REMOTE_SSH_HOST="64.225.88.152"
REMOTE_SSH_PORT=22
EP_TUNNEL_PORT=43022
EP_USER=root
EP_SSH_PRIVATE_KEY=/root/.ssh/id_rsa

ssh \
  -o StrictHostKeyChecking=no \
  -N -R ${EP_TUNNEL_PORT}:localhost:22 \
  ${REMOTE_SSH_USER}@${REMOTE_SSH_HOST} \
  -p ${REMOTE_SSH_PORT} \
  -i ${EP_SSH_PRIVATE_KEY} &

echo "[OKAY]  SSH tunnel to ${REMOTE_SSH_HOST} established"
exit 0