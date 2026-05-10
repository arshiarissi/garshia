# GH Tun (g2ray)

> Simple Xray VLESS tunnel for GitHub Codespaces

---

## ⚠️ DISCLAIMERS

> [!WARNING]
> **Educational use only.** You are responsible for complying with all laws and GitHub's Terms of Service.

> [!CAUTION]
> Don't use this for illegal activities, bypassing restrictions, or violating any platform rules.

---

## 📋 Prerequisites

- GitHub account with Codespaces access
- A VLESS-compatible client (Hiddify, Nekobox, v2rayNG, Streisand, etc.)
- Basic terminal knowledge

---

## ✅ Pre-Connection Test (Run on YOUR local machine)

**Before creating a Codespace, test these IPs from your local terminal:**

```bash
# Test each server (Ctrl+C to stop after 3-4 pings)
ping 63.141.252.203   # USA Server
ping 50.7.5.83        # Ireland Server
ping 94.130.50.12     # Germany Server
```

**On Windows (PowerShell):**
```powershell
Test-Connection 63.141.252.203 -Count 4
Test-Connection 50.7.5.83 -Count 4
Test-Connection 94.130.50.12 -Count 4
```

> [!NOTE]
> - **✅ If they ping back** → You can connect directly
> - **❌ If they don't ping** → Your ISP is blocking them. Try:
>   - Using Shecan DNS (visit [shecan.ir](https://shecan.ir) for setup guide)

**📝 WRITE DOWN which IPs worked for you!** You'll need this in the next step.

---

## 🚀 Quick Start

### Step 1: Create Codespace
1. Click the **"Code"** button → **"Codespaces"** → **"Create codespace on main"**
2. Wait for the container to build (~1-2 minutes)

### Step 2: Select Your Working Server
When prompted in the terminal, enter the number of the server that worked in your ping test:

```
=========================================
🌐 GH TUN SETUP
=========================================

Based on your local ping test earlier, which server was reachable?

  1) Germany  - 94.130.50.12
  2) USA      - 63.141.252.203
  3) Ireland - 50.7.5.83

Enter choice [1-3]: 
```

### Step 3: Copy Your VLESS Link
After selection, you'll see your unique connection string:

```
=========================================
🔗 CONNECTION STRING
=========================================
vless://550e8400-e29b-41d4-a716-446655440000@94.130.50.12:443?encryption=none&security=tls&type=xhttp&mode=packet-up&sni=your-codespace-443.app.github.dev&path=%2F#ghtun
=========================================
```

### Step 4: Connect
1. Copy the entire VLESS link
2. Open your VLESS client (Hiddify, Nekobox, v2rayNG, etc.)
3. Import from clipboard or add manually
4. Connect!

---

## 🔧 Useful Commands (inside Codespace)

Open a new terminal in the Codespace and use these aliases:

| Command | What it does |
|---------|---------------|
| `xray-status` | Check if Xray is running, show connection string |
| `xray-restart` | Restart Xray service |
| `xray-link` | Display your VLESS connection string again |

**Manual commands:**
```bash
# Check logs
tail -f /tmp/xray.log

# Check if port is listening
ss -tlnp | grep 443

# Check Xray version
/usr/local/bin/xray -version
```

---

## ✅ Verification

The script automatically verifies everything on start:

```bash
=========================================
🔍 XRAY VERIFICATION
=========================================
📋 Server: 94.130.50.12 | UUID: 550e8400...440000

✅ Xray is running (PID: 1234)

📡 PORT:
✅ Port 443 listening

🔗 CONNECTION STRING:
vless://550e8400-e29b-41d4-a716-446655440000@94.130.50.12:443?encryption=none&security=tls&type=xhttp&mode=packet-up&sni=your-codespace-443.app.github.dev&path=%2F#ghtun
=========================================
```

---

## ⚙️ Configuration Details

| Parameter | Value |
|-----------|-------|
| **Protocol** | VLESS |
| **Port** | 443 |
| **Transport** | xHTTP (packet-up mode) |
| **Security** | TLS (provided by GitHub) |
| **Encryption** | none |
| **UUID** | Randomly generated per Codespace |

### How it works
1. Xray runs inside your Codespace listening on port 443
2. GitHub automatically forwards `https://{CODESPACE_NAME}-443.app.github.dev` to port 443
3. TLS is terminated by GitHub's proxy, so Xray doesn't need certificates
4. Traffic is tunneled through the chosen server

---

## 🐛 Troubleshooting

### "No reachable servers" during ping test
- **Problem:** All 3 IPs timed out
- **Solution:** 
  - Use a different ISP
  - Setup [Shecan DNS](https://shecan.ir) (or any other alternative)

### Xray not starting
```bash
# Check error logs
cat /tmp/xray_error.log

# Try manual start
/usr/local/bin/xray -c /etc/config.json

# Check config syntax
/usr/local/bin/xray -test -c /etc/config.json
```

### Port 443 not public
```bash
# Make port public manually
gh codespace ports visibility 443:public -c $CODESPACE_NAME

# Check port status
gh codespace ports -c $CODESPACE_NAME
```

### Can't connect with client
- Verify the VLESS link is complete (no line breaks)
- Check that the server IP matches what you selected
- Ensure you're using the correct SNI (should be your codespace URL)
- Try restarting Xray: `xray-restart`

### Codespace shuts down
- Free tier Codespaces auto-sleep after 30 minutes of inactivity
- Premium codespaces have longer limits
- Just restart the Codespace and reconnect

---

## 🔒 Security Notes

- **Each Codespace generates a unique UUID** - no shared secrets
- **Traffic is tunneled but NOT encrypted by Xray** (GitHub's TLS handles encryption)
- **Logs are rotated daily** - auto cleanup after 3 rotations or 10MB
- **Don't share your Codespace URL** - it's publicly accessible if port is public
- **Delete the Codespace when done** to free resources and close the tunnel

---

## 📁 File Structure

```
.devcontainer/
├── Dockerfile          # Container definition
├── devcontainer.json   # Codespace configuration  
├── config.json         # Xray config template
├── install.sh          # Xray binary installer
└── start.sh           # Interactive setup + Xray runner
```

---

## 🙏 Credits

I am **not** the original author of this work. I only expanded on it and use it for my personal needs (while respecting this platforms TOS, of course).

**Support the original creator:**

[!["Buy Me A Coffee"](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-ffdd00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://www.buymeacoffee.com/amiremohamadi)

---

This project is for **educational purposes only**. Use at your own risk.

---

## ❓ FAQ

**Q: Why do I need to ping test locally?**  
A: Some ISPs block these servers. Testing locally first saves you from creating a Codespace that won't work.

**Q: Can I change the server after setup?**  
A: Yes, delete `/etc/config.json` and `/app/uuid.txt`, then restart the Codespace.

**Q: Is this faster than a regular VPN?**  
A: Performance depends on GitHub's infrastructure and your selected server. Usually decent for web browsing.

**Q: Will GitHub ban me for this?**  
A: Possibly. This violates Codespaces' intended use (computing/proxy). Use at your own risk.

**Q: Can I use this on mobile?**  
A: Yes, any VLESS client works. Copy the link to your phone via QR code or manual entry.

**Q: How do I get a QR code?**  
A: Most clients can generate QR from VLESS link. Or use online QR generators (careful with privacy).

**Q: The connection drops often**  
A: Try a different server or restart Xray with `xray-restart`.

---

## 🎯 Quick Reference Card

```bash
# Local PC (before creating Codespace)
ping 94.130.50.12     # Test Germany
ping 63.141.252.203   # Test USA  
ping 50.7.5.83        # Test Ireland

# Inside Codespace (after setup)
xray-status           # Show status & link
xray-restart          # Restart service
xray-link            # Show connection string
tail -f /tmp/xray.log # Watch logs
```

---
