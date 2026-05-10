#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ -f /etc/config.json ] && [ -f /app/uuid.txt ]; then
    echo -e "${GREEN}✅ Already configured. Starting Xray...${NC}"
    /usr/local/bin/xray -c /etc/config.json > /tmp/xray.log 2>&1 &
    
    if [ ! -f /app/verify.sh ]; then
        cat > /app/verify.sh <<'VERIFYEOF'
#!/bin/bash
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
echo ""
echo "========================================="
echo "🔍 XRAY VERIFICATION"
echo "========================================="
if [ -f /app/uuid.txt ] && [ -f /app/selected_ip.txt ]; then
    UUID=$(cat /app/uuid.txt)
    SELECTED_IP=$(cat /app/selected_ip.txt)
    echo -e "${BLUE}📋 Server: ${SELECTED_IP} | UUID: ${UUID:0:8}...${UUID: -8}${NC}"
    echo ""
fi
if pgrep -x xray > /dev/null; then
    echo -e "${GREEN}✅ Xray is running (PID: $(pgrep -x xray))${NC}"
else
    echo -e "${RED}❌ Xray is NOT running${NC}"
fi
echo ""
echo "📡 PORT:"
ss -tlnp 2>/dev/null | grep -q ":443" && echo -e "${GREEN}✅ Port 443 listening${NC}" || echo -e "${RED}❌ Port 443 not listening${NC}"
if [ -n "$CODESPACE_NAME" ] && [ -f /app/uuid.txt ]; then
    echo ""
    echo "🔗 CONNECTION STRING:"
    echo -e "${GREEN}vless://$(cat /app/uuid.txt)@$(cat /app/selected_ip.txt):443?encryption=none&security=tls&type=xhttp&mode=packet-up&sni=${CODESPACE_NAME}-443.app.github.dev&path=%2F#ghtun${NC}"
fi
echo "========================================="
VERIFYEOF
        chmod +x /app/verify.sh
    fi
    
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
echo "  3) Ireland - 50.7.5.83"
echo ""

while true; do
    read -p "Enter choice [1-3]: " choice
    case $choice in
        1) SELECTED_IP="94.130.50.12"; SELECTED_NAME="Germany"; break;;
        2) SELECTED_IP="63.141.252.203"; SELECTED_NAME="USA"; break;;
        3) SELECTED_IP="50.7.5.83"; SELECTED_NAME="Ireland"; break;;
        *) echo -e "${RED}Invalid choice. Try again.${NC}";;
    esac
done

echo ""
echo -e "${GREEN}✓ Selected: ${SELECTED_NAME} (${SELECTED_IP})${NC}"

UUID=$(cat /proc/sys/kernel/random/uuid)
echo "$UUID" > /app/uuid.txt
echo "$SELECTED_IP" > /app/selected_ip.txt

sed -e "s/__UUID__/${UUID}/g" /etc/config.json.template > /etc/config.json

echo -e "${GREEN}✓ Configuration generated${NC}"
echo -e "${BLUE}✓ UUID: ${UUID}${NC}"

cat > /app/verify.sh <<'VERIFYEOF'
#!/bin/bash
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
echo ""
echo "========================================="
echo "🔍 XRAY VERIFICATION"
echo "========================================="
if [ -f /app/uuid.txt ] && [ -f /app/selected_ip.txt ]; then
    UUID=$(cat /app/uuid.txt)
    SELECTED_IP=$(cat /app/selected_ip.txt)
    echo -e "${BLUE}📋 Server: ${SELECTED_IP} | UUID: ${UUID:0:8}...${UUID: -8}${NC}"
    echo ""
fi
if pgrep -x xray > /dev/null; then
    echo -e "${GREEN}✅ Xray is running (PID: $(pgrep -x xray))${NC}"
else
    echo -e "${RED}❌ Xray is NOT running${NC}"
    /usr/local/bin/xray -c /etc/config.json > /tmp/xray.log 2>&1 &
    sleep 2
    pgrep -x xray > /dev/null && echo -e "${GREEN}✅ Xray started${NC}" || echo -e "${RED}❌ Failed to start${NC}"
fi
echo ""
echo "📡 PORT:"
ss -tlnp 2>/dev/null | grep -q ":443" && echo -e "${GREEN}✅ Port 443 listening${NC}" || echo -e "${RED}❌ Port 443 not listening${NC}"
if [ -n "$CODESPACE_NAME" ] && [ -f /app/uuid.txt ]; then
    echo ""
    echo "🔗 CONNECTION STRING:"
    echo -e "${GREEN}vless://$(cat /app/uuid.txt)@$(cat /app/selected_ip.txt):443?encryption=none&security=tls&type=xhttp&mode=packet-up&sni=${CODESPACE_NAME}-443.app.github.dev&path=%2F#GH-Tun${NC}"
fi
echo "========================================="
VERIFYEOF

chmod +x /app/verify.sh

echo ""
echo "🚀 Starting Xray..."
/usr/local/bin/xray -c /etc/config.json > /tmp/xray.log 2>&1 &
sleep 2

/app/verify.sh

echo ""
echo -e "${GREEN}✅ Ready! Copy the connection string above${NC}"
echo "========================================="

tail -f /tmp/xray.log