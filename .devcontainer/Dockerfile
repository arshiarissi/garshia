FROM debian:bookworm-slim

COPY install.sh /app/install.sh
COPY config.json /etc/config.json.template
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash git curl wget unzip tzdata openssl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN chmod +x /app/install.sh && /app/install.sh

RUN echo 'alias xray-status="/app/verify.sh"' >> /etc/bash.bashrc
RUN echo 'alias xray-restart="pkill xray && /usr/local/bin/xray -c /etc/config.json > /tmp/xray.log 2>&1 & && echo \"✅ Xray restarted\""' >> /etc/bash.bashrc
RUN echo 'alias xray-link="[ -f /app/uuid.txt ] && [ -f /app/selected_ip.txt ] && echo \"vless://$(cat /app/uuid.txt)@$(cat /app/selected_ip.txt):443?encryption=none&security=tls&type=xhttp&mode=packet-up&sni=${CODESPACE_NAME}-443.app.github.dev&path=%2F#ghtun\" || echo \"❌ Config not found\""' >> /etc/bash.bashrc

RUN cat > /etc/logrotate.d/xray <<'EOF'
/tmp/xray.log /tmp/xray_error.log {
    daily; rotate 3; size 10M; compress; delaycompress; missingok; notifempty; create 644 root root
}
EOF

CMD ["/app/start.sh"]