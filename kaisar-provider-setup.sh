#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo: sudo ./kaisar-provider-setup.sh"
  exit 1
fi

INSTALL_DIR="/opt/kaisar-provider-cli-2508100315"
DATA_DIR="/var/lib/kaisar-provider-cli"
ARCHIVE_URL="https://github.com/Kaisar-Network/kaisar-releases/raw/main/kaisar-provider-cli-2508100315.tar.gz"

export KAISAR_DATA_DIR="$DATA_DIR"

if [ ! -d "$INSTALL_DIR" ]; then
  echo "Downloading Kaisar CLI..."
  curl -L "$ARCHIVE_URL" -o /tmp/kaisar-cli.tar.gz
  mkdir -p "$INSTALL_DIR"
  tar -xzf /tmp/kaisar-cli.tar.gz -C "$INSTALL_DIR" --strip-components=1
fi

# Installation Node
cd "$INSTALL_DIR" || exit 1
npm install

echo "Linking CLI globally..."
npm link
if [ $? -ne 0 ]; then
  echo "Error: Unable to link CLI globally. Please check your npm permissions."
  exit 1
fi

echo "✅ Kaisar CLI installed successfully!"
