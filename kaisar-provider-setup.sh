#!/bin/bash
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo: sudo ./kaisar-provider-setup.sh"
  exit 1
fi
INSTALL_DIR="/opt/kaisar-provider-cli-2508100315"
DATA_DIR="/var/lib/kaisar-provider-cli"
export KAISAR_DATA_DIR="$DATA_DIR"
echo "Linking CLI globally..."
cd "$INSTALL_DIR"
npm link
if [ $? -ne 0 ]; then
  echo "Error: Unable to link CLI globally. Please check your npm permissions."
  exit 1
fi
