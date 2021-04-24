#!/bin/bash
# Reverse Tunnel - Evaluation
# Determine if the Reverse Tunnel should run.
# Here we download a public ssh key that we will add to the device's authorized keys file so that
# when a tunnel is established the private half of this key can be used to log in to the device's
# shell.

set -e

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