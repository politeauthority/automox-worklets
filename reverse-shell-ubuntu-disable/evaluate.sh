#!/bin/bash
# Reverse Tunnel - Disable - Evaluate
# Check to see if the tunnel is already running, if it is exit 0, nothing more to do.

set -eu


SERVICE="ssh"
if pgrep -x "$SERVICE" >/dev/null
then
    echo "Tunnel may be running. exit 1"
    exit 1
else
    echo "Tunnel may not be running."
    exit 0
fi
