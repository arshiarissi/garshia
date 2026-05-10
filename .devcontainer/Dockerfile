FROM debian:bookworm-slim

COPY config.json /etc/config.json.template
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash git curl wget unzip tzdata openssl ca-certificates iputils-ping \
    && rm -rf /var/lib/apt/lists/*

RUN echo "📦 Installing Xray..." && \
    wget -q -O xray.zip https://github.com/XTLS/Xray-core/releases/download/v26.3.27/Xray-linux-64.zip && \
    unzip -q xray.zip && \
    chmod +x xray && \
    mv xray /usr/local/bin/xray && \
    rm -f xray.zip && \
    echo "✅ Xray installed"

RUN cat > /app/verify.sh <<'VERIFYEOF'
#!/bin/bash
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
echo ""
echo "========================================="
echo "🔍 XRAY VERIFICATION"
echo "========================================="

echo ""
echo "📝 CONFIGURATION CHECK:"
if /usr/local/bin/xray -test -c /etc/config.json 2>/dev/null; then
    echo -e "${GREEN}✅ Config syntax valid${NC}"
else
    echo -e "${RED}❌ Config syntax invalid${NC}"
fi

if [ -f /app/uuid.txt ] && [ -f /app/selected_ip.txt ]; then
    UUID=$(cat /app/uuid.txt)
    SELECTED_IP=$(cat /app/selected_ip.txt)
    echo ""
    echo -e "${BLUE}📋 Active Server: ${SELECTED_IP}${NC}"
    echo -e "${BLUE}🔑 UUID: ${UUID:0:8}...${UUID: -8}${NC}"
fi

echo ""
echo "🔍 SERVICE STATUS:"
if pgrep -x xray > /dev/null; then
    echo -e "${GREEN}✅ Xray is running (PID: $(pgrep -x xray))${NC}"
else
    echo -e "${RED}❌ Xray is NOT running${NC}"
fi

echo ""
echo "📡 PORT STATUS:"
if ss -tlnp 2>/dev/null | grep -q ":443"; then
    echo -e "${GREEN}✅ Port 443 is listening${NC}"
else
    echo -e "${RED}❌ Port 443 is NOT listening${NC}"
fi

echo ""
echo "📋 LOG STATUS:"
if [ -f /tmp/xray.log ]; then
    LOG_SIZE=$(du -h /tmp/xray.log | cut -f1)
    echo -e "${GREEN}✅ Main log: /tmp/xray.log (${LOG_SIZE})${NC}"
fi
if [ -f /tmp/xray_error.log ] && [ -s /tmp/xray_error.log ]; then
    echo -e "${YELLOW}⚠️  Errors detected in /tmp/xray_error.log${NC}"
    echo -e "${YELLOW}Last 3 errors:${NC}"
    tail -3 /tmp/xray_error.log | while read line; do echo "  $line"; done
fi

if [ -n "$CODESPACE_NAME" ] && [ -f /app/uuid.txt ] && [ -f /app/selected_ip.txt ]; then
    echo ""
    echo "========================================="
    echo "🔗 CURRENT VLESS CONNECTION STRING"
    echo "========================================="
    echo -e "${GREEN}vless://$(cat /app/uuid.txt)@$(cat /app/selected_ip.txt):443?encryption=none&security=tls&type=xhttp&mode=packet-up&sni=${CODESPACE_NAME}-443.app.github.dev&path=%2F#GH-Tun${NC}"
    echo "========================================="
fi

if [ -n "$CODESPACE_NAME" ]; then
    echo ""
    echo "🌐 PUBLIC ACCESS URL:"
    echo -e "${GREEN}https://${CODESPACE_NAME}-443.app.github.dev${NC}"
fi
echo ""
VERIFYEOF

RUN chmod +x /app/verify.sh

RUN cat > /app/start.sh <<'STARTEOF'
#!/bin/bash
set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

if [ -f /etc/config.json ] && [ -f /app/uuid.txt ] && [ -f /app/selected_ip.txt ]; then
    echo -e "${GREEN}✅ Already configured. Starting Xray...${NC}"
    /usr/local/bin/xray -c /etc/config.json > /tmp/xray.log 2>&1 &
    /app/verify.sh
    tail -f /tmp/xray.log
    exit 0
fi

echo ""
echo "========================================="
echo "🌐 GH TUN SETUP"
echo "========================================="
echo ""
echo "Based on your local ping test earlier, which server was reachable?"
echo ""
echo "  1) Germany  - 94.130.50.12"
echo "  2) USA      - 63.141.252.203"
echo "  3) Netherlands - 50.7.5.83"
echo ""

while true; do
    read -p "Enter choice [1-3]: " choice
    case $choice in
        1) SELECTED_IP="94.130.50.12"; SELECTED_NAME="Germany"; break;;
        2) SELECTED_IP="63.141.252.203"; SELECTED_NAME="USA"; break;;
        3) SELECTED_IP="50.7.5.83"; SELECTED_NAME="Netherlands"; break;;
        *) echo -e "${RED}Invalid choice. Try again.${NC}";;
    esac
done

echo ""
echo -e "${GREEN}✓ Selected: ${SELECTED_NAME} (${SELECTED_IP})${NC}"

UUID=$(cat /proc/sys/kernel/random/uuid)
echo "$UUID" > /app/uuid.txt
echo "$SELECTED_IP" > /app/selected_ip.txt

sed -e "s/__UUID__/${UUID}/g" /etc/config.json.template > /etc/config.json

echo ""
echo "📝 Validating configuration..."
if /usr/local/bin/xray -test -c /etc/config.json 2>/dev/null; then
    echo -e "${GREEN}✅ Config valid${NC}"
else
    echo -e "${RED}❌ Config invalid${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Configuration generated${NC}"
echo -e "${BLUE}✓ UUID: ${UUID}${NC}"

echo ""
echo "🚀 Starting Xray..."
/usr/local/bin/xray -c /etc/config.json > /tmp/xray.log 2>&1 &
sleep 2

/app/verify.sh

echo ""
echo -e "${GREEN}✅ Ready! Copy the connection string above${NC}"
echo "========================================="

tail -f /tmp/xray.log
STARTEOF

RUN chmod +x /app/start.sh

RUN echo 'alias xray-status="/app/verify.sh"' >> /etc/bash.bashrc
RUN echo 'alias xray-restart="pkill xray && /usr/local/bin/xray -c /etc/config.json > /tmp/xray.log 2>&1 & && echo \"✅ Xray restarted\""' >> /etc/bash.bashrc
RUN echo 'alias xray-link="[ -f /app/uuid.txt ] && [ -f /app/selected_ip.txt ] && echo \"vless://$(cat /app/uuid.txt)@$(cat /app/selected_ip.txt):443?encryption=none&security=tls&type=xhttp&mode=packet-up&sni=${CODESPACE_NAME}-443.app.github.dev&path=%2F#GH-Tun\" || echo \"❌ Config not found\""' >> /etc/bash.bashrc

RUN cat > /etc/logrotate.d/xray <<'LOGROTEOF'
/tmp/xray.log /tmp/xray_error.log {
    daily; rotate 3; size 10M; compress; delaycompress; missingok; notifempty; create 644 root root
}
LOGROTEOF

RUN sed -i '/vless:\/\//d' /etc/bash.bashrc 2>/dev/null || true

CMD ["/app/start.sh"]