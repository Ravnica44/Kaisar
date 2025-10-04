#!/bin/bash

# Script to install and set up the Kaisar CLI on Ubuntu

# Check for root privileges
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

# Install Node.js and npm (version 18.x)
echo "Installing Node.js and npm..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt update
apt install -y nodejs

# Check Node.js and npm versions
node -v
npm -v

# Install pm2 globally
echo "Installing pm2..."
npm install -g pm2

# Check and install curl if not present
if ! command -v curl &> /dev/null; then
  echo "Installing curl..."
  apt install -y curl
fi

# Get latest version info from Kaisar API
echo "Checking latest Kaisar Provider CLI version..."
API_URL="https://app-api.kaisar.io/kavm/check-version/0?app=provider-cli&platform=linux"
VERSION_INFO=$(curl -fsSL "$API_URL")
DOWNLOAD_URL=$(echo "$VERSION_INFO" | grep -oP '"downloadUrl"\s*:\s*"\K[^"]+')
LATEST_VERSION=$(echo "$VERSION_INFO" | grep -oP '"latestVersion"\s*:\s*"\K[^"]+')

if [ -z "$DOWNLOAD_URL" ]; then
  echo "Error: Could not fetch download URL from API."
  exit 1
fi

# Prepare install directory
INSTALL_DIR="/opt/kaisar-provider-cli-$LATEST_VERSION"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Create data directory with proper permissions for all users
DATA_DIR="/var/lib/kaisar-provider-cli"
sudo mkdir -p "$DATA_DIR"
sudo chmod 777 "$DATA_DIR"

# Download and extract the release package
echo "Downloading Kaisar Provider CLI package from $DOWNLOAD_URL..."
curl -fL "$DOWNLOAD_URL" -o kaisar-provider-cli.tar.gz
if [ $? -ne 0 ]; then
  echo "Error: Unable to download package."
  exit 1
fi

echo "Extracting package..."
tar -xzf kaisar-provider-cli.tar.gz
rm kaisar-provider-cli.tar.gz

# Install dependencies (if package.json exists)
if [ -f package.json ]; then
  echo "Installing dependencies..."
  npm install
else
  echo "Error: package.json not found in extracted package."
  exit 1
fi

# Link CLI globally with KAISAR_DATA_DIR environment variable
export KAISAR_DATA_DIR="$DATA_DIR"
echo "Linking CLI globally..."
cd "$INSTALL_DIR"
npm link
if [ $? -ne 0 ]; then
  echo "Error: Unable to link CLI globally. Please check your npm permissions."
  exit 1
fi

pm2 delete kaisar-provider || true

# Verify installation
echo "Verifying installation..."
kaisar
EXIT_CODE=$?
if [ $EXIT_CODE -eq 0 ] || [ $EXIT_CODE -eq 1 ]; then
  echo "Installation successful! You can now use the CLI with the 'kaisar' command."
  echo "Example: kaisar start (to start the Provider Application)"
  echo "Example: kaisar status (to check the status of the Provider Application)"
else
  echo "Error: Installation failed. Please check the logs above."
  exit 1
fi
