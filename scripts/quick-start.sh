#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -f $SCRIPT_DIR/client-bootstrap.sh ]; then
  exec $SCRIPT_DIR/client-bootstrap.sh
else
  echo "client-bootstrap.sh not found."
fi
