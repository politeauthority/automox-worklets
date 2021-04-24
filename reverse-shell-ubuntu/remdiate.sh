#!/bin/bash
# Reverse Tunnel - Remediation
set -e

REMOTE_SSH_USER="root"
REMOTE_SSH_HOST="64.225.88.152"
REMOTE_SSH_PORT=22
REMOTE_PUBLIC_KEY=https://f001.backblazeb2.com/file/polite-pub/automox-worklets/automox-remote-2.pub
EP_TUNNEL_PORT=43022
# Extras for printing SSH command
EP_USER="root"
REMOTE_PRIVATE_KEY="/root/data/openssh/keys/automox-remote"

# If the user is root, make special accommodations of ssh paths
if [ "$EP_USER" = "root" ]; then
    EP_SSH_KEY="/root/.ssh/id_rsa"
    EP_SSH_AUTHORIZED_KEYS="/root/.ssh/authorized_keys"
else
    echo "REMOTE_SSH_USER is NOT root.\n"
    EP_SSH_KEY="/home/${EP_USER}/.ssh/id_rsa"
    EP_SSH_AUTHORIZED_KEYS="/home/${REMOTE_SSH_USER}/.ssh/authorized_keys"
fi
EP_SSH_PUBLIC_KEY="${EP_SSH_KEY}.pub"


# Check for a ssh key pair on the endpoint, if there isn't one generate one and echo it.
if ! test -f ${EP_SSH_KEY}; then
    echo "Generating SSH key pair.\n"
    echo "${EP_SSH_KEY} does not exist, generating now.\n"
    ssh-keygen -b 2048 -t rsa -f ${EP_SSH_KEY} -q -N ""
    PUBLIC_KEY=$(cat ${EP_SSH_PUBLIC_KEY})
fi


# Fetch the remote public key and add it to the device's authorized_keys file if it does not exist
# there already
wget ${REMOTE_PUBLIC_KEY} --quiet -O remote_public_key.pub
if test -f ${EP_SSH_AUTHORIZED_KEYS}; then
    PUBLIC_KEY_VALUE=$(cat remote_public_key.pub)
    if ! cat ${EP_SSH_AUTHORIZED_KEYS} | grep "${PUBLIC_KEY_VALUE}"; then
        echo "Remote key not present, adding\n"
        cat remote_public_key.pub >> ${EP_SSH_AUTHORIZED_KEYS}
    fi
fi
rm remote_public_key.pub


# Start the SSH tunnel.
ssh \
  -o StrictHostKeyChecking=no \
  -N -R ${EP_TUNNEL_PORT}:localhost:22 \
  ${REMOTE_SSH_USER}@${REMOTE_SSH_HOST} \
  -p ${REMOTE_SSH_PORT} \
  -i ${EP_SSH_KEY} &


PUBLIC_KEY=$(cat ${EP_SSH_PUBLIC_KEY})

echo "[OKAY]  SSH tunnel to ${REMOTE_SSH_HOST} established"
echo "Run the following from the remote"
echo 'echo "${PUBLIC_KEY}" >> ~/.ssh/authorized_keys'
echo "ssh -o StrictHostKeyChecking=no ${EP_USER}@localhost -p ${EP_TUNNEL_PORT} -i ${REMOTE_PRIVATE_KEY}"
exit 0