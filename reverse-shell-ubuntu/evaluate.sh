#!/bin/bash
# Reverse Tunnel - Evaluation
# Determine if the Reverse Tunnel should run.
# Here we download a public ssh key that we will add to the device's authorized keys file so that
# when a tunnel is established the private half of this key can be used to log in to the device's
# shell.

set -e

EP_USER=root
REMOTE_PUBLIC_KEY=https://f001.backblazeb2.com/file/polite-pub/automox-worklets/automox-remote-2.pub

EP_SSH_AUTHORIZED_KEYS="${HOME}/.ssh/authorized_keys"


# Fetch the remote public key and add it to the device's authorized_keys file if it does not exist
# there already
wget ${REMOTE_PUBLIC_KEY} --quiet -O remote_public_key.pub
if test -f ${EP_SSH_AUTHORIZED_KEYS}; then
    echo "${EP_SSH_AUTHORIZED_KEYS} exists."
    # echo "cat ${AUTHORIZED_KEY_FILE} | grep eval(cat remote_public_key.pub)"
    PUBLIC_KEY_VALUE=$(cat remote_public_key.pub)
    if ! cat ${EP_SSH_AUTHORIZED_KEYS} | grep "${PUBLIC_KEY_VALUE}"; then
        echo "Remote key not present, adding"
        cat remote_public_key.pub >> ${EP_SSH_AUTHORIZED_KEYS}
    else
        echo "Remote key present."
    fi
fi
rm remote_public_key.pub

# Check to see if the tunnel is already running, if it is exit 0, nothing more to do.
# Otherwise we'll exit 1, so then remediation will run.
SERVICE="ssh"
if pgrep -x "$SERVICE" >/dev/null
then
    echo "Tunnel may already be running. exit 0"
    exit 0
else
    echo "Tunnel service does not appear to be running."
    exit 1
fi