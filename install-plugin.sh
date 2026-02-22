#!/bin/sh

cd /workspace/ComfyUI/custom_nodes
CUSTOM_NODES_URL="$1"
CUSTOM_NODES_NAME="$2"

echo "INSTALLING CUSTOM NODES $CUSTOM_NODES_NAME"
git clone --depth 1 "$CUSTOM_NODES_URL" "$CUSTOM_NODES_NAME"
if [ -f $CUSTOM_NODES_NAME/requirements.txt ]
then
  /venv/main/bin/python -m pip install -U -r $CUSTOM_NODES_NAME/requirements.txt
fi
