#!/bin/bash
# Script to install and manage Kaisar Provider CLI with PM2

# Variables
VERSION="2508100315"
DIR="/opt/kaisar-provider-cli-$VERSION"
ARCHIVE="kaisar-provider-cli-$VERSION.tar.gz"
URL="https://github.com/Kaisar-Network/kaisar-releases/raw/refs/heads/main/kaisar-provider-cli-2508100315.tar.gz"
PROCESS_NAME="kaisar-provider"

# 1️⃣ Download the release from GitHub
echo "Downloading release $VERSION..."
curl -L -o $ARCHIVE "$URL"

# 2️⃣ Create a dedicated folder
echo "Creating folder $DIR..."
mkdir -p $DIR

# 3️⃣ Extract the archive
echo "Extracting the archive..."
tar -xzf $ARCHIVE -C $DIR

# 4️⃣ Go into the folder
cd $DIR || exit

# 5️⃣ Install npm dependencies
echo "Installing npm dependencies..."
npm install

# 6️⃣ Link the CLI globally
echo "Linking CLI globally..."
npm link

# 7️⃣ Check installed version
echo "Installed version:"
kaisar --version

# 8️⃣ Check if PM2 is installed, install if missing
if ! command -v pm2 &> /dev/null; then
    echo "PM2 not found, installing..."
    npm install -g pm2
fi

# 9️⃣ Delete the previous PM2 instance (if exists)
echo "Deleting old PM2 instance (if any)..."
pm2 delete $PROCESS_NAME 2>/dev/null || true

# 🔟 Flush PM2 logs
echo "Flushing PM2 logs..."
pm2 flush

# 1️⃣1️⃣ Start the Provider with PM2
echo "Starting the Provider with PM2..."
pm2 start "$DIR/dist/background/index.js" --name $PROCESS_NAME -f

# 1️⃣2️⃣ Configure PM2 to restart on system reboot
echo "Configuring PM2 for automatic startup..."
pm2 save
pm2 startup systemd -u root --hp /root

# 1️⃣3️⃣ Check PM2 process status
echo "PM2 process status:"
pm2 list

echo "Real-time logs (Ctrl+C to exit):"
pm2 logs $PROCESS_NAME
