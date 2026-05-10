#!/bin/bash
set -eu

echo "📦 Installing Xray..."
wget -q -O xray.zip https://github.com/XTLS/Xray-core/releases/download/v26.3.27/Xray-linux-64.zip
unzip -q xray.zip
chmod +x xray
mv xray /usr/local/bin/xray
rm -f xray.zip
echo "✅ Xray installed"