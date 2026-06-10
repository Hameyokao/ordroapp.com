#!/usr/bin/env bash
# =====================================================================
# ORDRO one-shot server setup for Oracle Cloud (Ubuntu)
# Usage:  sudo bash setup_server.sh ordroapp.com
# Run this from inside the ordro app folder after you clone it.
# =====================================================================
set -euo pipefail

DOMAIN="${1:-}"
if [ -z "$DOMAIN" ]; then
  echo "Usage: sudo bash setup_server.sh yourdomain.com"
  exit 1
fi

APP_DIR="$(pwd)"
SERVICE_USER="${SUDO_USER:-ubuntu}"
PERSIST_DIR="$APP_DIR/persist"

echo "==> [1/7] Installing system packages..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y python3 python3-venv python3-pip nginx git certbot python3-certbot-nginx iptables-persistent

echo "==> [2/7] Creating Python environment and installing the app..."
python3 -m venv "$APP_DIR/venv"
"$APP_DIR/venv/bin/pip" install --upgrade pip
"$APP_DIR/venv/bin/pip" install -r "$APP_DIR/requirements.txt"

echo "==> [3/7] Preparing persistent data folder (keeps your shop data safe)..."
mkdir -p "$PERSIST_DIR"
chown -R "$SERVICE_USER":"$SERVICE_USER" "$APP_DIR"

echo "==> [4/7] Adding 2 GB swap (helps on the small free instance)..."
if [ ! -f /swapfile ]; then
  fallocate -l 2G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

echo "==> [5/7] Creating the ORDRO background service..."
cat > /etc/systemd/system/ordro.service <<EOF
[Unit]
Description=ORDRO Streamlit app
After=network.target

[Service]
User=$SERVICE_USER
WorkingDirectory=$APP_DIR
Environment=ORDRO_DATA_DIR=$PERSIST_DIR
ExecStart=$APP_DIR/venv/bin/streamlit run app.py --server.port 8501 --server.address 127.0.0.1 --server.headless true --server.enableCORS false --server.enableXsrfProtection false
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable ordro
systemctl restart ordro

echo "==> [6/7] Configuring nginx (the web front door)..."
cat > /etc/nginx/sites-available/ordro <<EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    client_max_body_size 25M;

    location / {
        proxy_pass http://127.0.0.1:8501;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_read_timeout 86400;
    }
}
EOF

ln -sf /etc/nginx/sites-available/ordro /etc/nginx/sites-enabled/ordro
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl restart nginx

echo "==> [7/7] Opening firewall ports 80 and 443 on the server..."
iptables -I INPUT -p tcp --dport 80 -j ACCEPT
iptables -I INPUT -p tcp --dport 443 -j ACCEPT
netfilter-persistent save || true

echo ""
echo "============================================================"
echo " DONE. ORDRO is running."
echo " Test now in a browser using the server IP:  http://$(curl -s ifconfig.me || echo YOUR_SERVER_IP)"
echo ""
echo " NEXT STEPS:"
echo "  1) In the Oracle console, make sure the Security List allows"
echo "     incoming TCP on ports 80 and 443 (see the guide)."
echo "  2) Point $DOMAIN DNS at this server's IP at Squarespace."
echo "  3) Once the domain loads over http, turn on HTTPS with:"
echo "        sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN"
echo "============================================================"
