#!/bin/bash
# Reverse Tunnel - Disable - Remediation
set -e

SSH_PID=$(pgrep -x "ssh")
kill ${SSH_PID}
echo "Killed PID ${SSH_PID}"
exit 0