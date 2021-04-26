#!/bin/bash
# Reverse Tunnel - Evaluation
# Determine if the Reverse Tunnel should run by looking for an existing tunnel running on the
# device.

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