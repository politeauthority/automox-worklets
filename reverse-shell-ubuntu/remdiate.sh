#!/bin/bash
# Reverse Tunnel - Remediation
set -e

SSH_USER="root"
SSH_HOST="64.225.88.152"
SSH_PORT=22
TUNNEL_PORT=43022
EP_USER=kube
EP_PRIVATE_KEY=/home/kube/.ssh/id_rsa

ssh \
  -o StrictHostKeyChecking=no \
  -N -R ${TUNNEL_PORT}:localhost:22 \
  ${SSH_USER}@${SSH_HOST} \
  -p ${SSH_PORT} \
  -i ${EP_PRIVATE_KEY} &

echo "[OKAY]  SSH tunnel to ${SSH_HOST} established"
exit 0