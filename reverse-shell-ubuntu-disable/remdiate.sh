#!/bin/bash
# Reverse Tunnel - Disable - Remediate
# Look for the SSH process running the tunnel. If found, kill it.
set -eu


SERVICE="ssh"
if pgrep -x "$SERVICE" >/dev/null
then
    SSH_PID=$(pgrep -x "$SERVICE")
    kill ${SSH_PID}
    echo "Killed PID ${SSH_PID}"
    exit 0
else
    echo "Tunnel may not be running."
    exit 0
fi

