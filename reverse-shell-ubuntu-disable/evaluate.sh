#!/bin/bash
# Reverse Tunnel - Disable - Evaluation
set -e

# Check to see if the tunnel is already running, if it is exit 0, nothing more to do.
# Otherwise we'll exit 1, so then remediation will run.
SERVICE="ssh"
if pgrep -x "$SERVICE" >/dev/null
then
    echo "Tunnel may be running. exit 1"
    exit 1
else
    echo "Tunnel may not be running."
    exit 0
fi
