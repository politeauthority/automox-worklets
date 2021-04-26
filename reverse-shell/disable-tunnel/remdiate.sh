#!/bin/bash
# Reverse Tunnel Disable - Remediate
# Check to see if the tunnel is already running, if it is exit 0, nothing more to do.
set -eu


SEARCH_CMD=$(ps aux | grep localhost:22 | grep ssh | awk '{print $2}')
echo $SEARCH_CMD

re='^[0-9]+$'
if ! [[ $SEARCH_CMD =~ $re ]] ; then
   echo "Tunnel is not running" >&2; exit 1
else
    echo "Tunnel is running"
    kill ${SEARCH_CMD}
    echo "Killed tunnel"
    exit 0
fi
