#!/bin/bash
# Reverse Tunnel macOS - Remediate

set -eu
# User configurable variables
REMOTE_SSH_HOST="64.225.88.152"
REMOTE_SSH_PORT=2222
REMOTE_SSH_USER="automox"
REMOTE_PUBLIC_KEY=https://f001.backblazeb2.com/file/polite-pub/automox-worklets/automox-remote.pub
REMOTE_PRIVATE_KEY="/root/data/openssh/keys/automox-remote"
EP_TUNNEL_PORT=43025
# End user configurable variables
EP_USER="root"


# Check the OS we're running on.
if [ "$(uname)" == "Darwin" ]; then
    # Do something under Mac OS X platform
    OS_KIND='macOS'
    ROOT_HOME="/var/root"
    echo 'its mac'
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    # Do something under GNU/Linux platform
    OS_KIND='linux'
    ROOT_HOME="/root"
    echo 'its Linux'
fi

# Check for an ssh key pair on the endpoint, if there isn't one generate one and echo it.
EP_SSH_KEY="${ROOT_HOME}/.ssh/id_rsa"
EP_SSH_AUTHORIZED_KEYS="${ROOT_HOME}/.ssh/authorized_keys"
EP_SSH_PUBLIC_KEY="${EP_SSH_KEY}.pub"
if ! test -f ${EP_SSH_KEY}; then
    echo "Generating SSH key pair.\n"
    echo "${EP_SSH_KEY} does not exist, generating now.\n"
    ssh-keygen -b 2048 -t rsa -f ${EP_SSH_KEY} -q -N ""
    PUBLIC_KEY=$(cat ${EP_SSH_PUBLIC_KEY})
fi

# Fetch the remote public key and add it to the device's authorized_keys file if it does not exist
# there already.
curl ${REMOTE_PUBLIC_KEY} --silent --output remote_public_key.pub
if test -f ${EP_SSH_AUTHORIZED_KEYS}; then
    PUBLIC_KEY_VALUE=$(cat remote_public_key.pub)
    if ! cat ${EP_SSH_AUTHORIZED_KEYS} | grep "${PUBLIC_KEY_VALUE}"; then
        echo "Remote key not present, adding\n"
        cat remote_public_key.pub >> ${EP_SSH_AUTHORIZED_KEYS}
    fi
fi
rm remote_public_key.pub

PUBLIC_KEY=$(cat ${EP_SSH_PUBLIC_KEY})
echo "Run the following from the remote to add the device key                                     "
echo "echo ${PUBLIC_KEY} >> ~/.ssh/authorized_keys"

# Start the SSH tunnel.
ssh \
  -o StrictHostKeyChecking=no \
  -f \
  -N -R ${EP_TUNNEL_PORT}:localhost:22 \
  ${REMOTE_SSH_USER}@${REMOTE_SSH_HOST} \
  -p ${REMOTE_SSH_PORT} \
  -i ${EP_SSH_KEY}

echo "[OKAY]  SSH tunnel to ${REMOTE_SSH_HOST} established"
echo "ssh -o StrictHostKeyChecking=no ${EP_USER}@localhost -p ${EP_TUNNEL_PORT} -i ${REMOTE_PRIVATE_KEY}"
exit 0