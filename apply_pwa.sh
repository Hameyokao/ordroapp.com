#!/usr/bin/env bash
# =====================================================================
# Adds the ToyLab home-screen app icon + name to the live site.
# Safe: it tests the new web-server config and only applies it if valid,
# otherwise it restores the previous config automatically.
# Run with:  sudo bash apply_pwa.sh
# =====================================================================
set -euo pipefail

DOMAIN="ordroapp.com"
APP_DIR="/opt/ordro"
CONF="/etc/nginx/sites-available/ordro"
CERT_DIR="/etc/letsencrypt/live/$DOMAIN"
BACKUP="${CONF}.bak.$(date +%s)"

if [ ! -d "$CERT_DIR" ]; then
  echo "ERROR: SSL certificate folder not found at $CERT_DIR"; exit 1
fi

cp "$CONF" "$BACKUP"
echo "Backed up current config to $BACKUP"

# Make sure nginx can read the icon files
chmod -R a+rX "$APP_DIR/pwa"

SSL_OPTS=""
[ -f /etc/letsencrypt/options-ssl-nginx.conf ] && SSL_OPTS="    include /etc/letsencrypt/options-ssl-nginx.conf;"
DH=""
[ -f /etc/letsencrypt/ssl-dhparams.pem ] && DH="    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;"

INJECT='<link rel="apple-touch-icon" href="/pwa/apple-touch-icon.png"><link rel="manifest" href="/pwa/manifest.json"><meta name="apple-mobile-web-app-capable" content="yes"><meta name="apple-mobile-web-app-status-bar-style" content="black"><meta name="apple-mobile-web-app-title" content="ToyLab"><link rel="icon" href="/pwa/favicon-32.png"></head>'

cat > "$CONF" <<EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name $DOMAIN www.$DOMAIN;

    ssl_certificate $CERT_DIR/fullchain.pem;
    ssl_certificate_key $CERT_DIR/privkey.pem;
$SSL_OPTS
$DH

    client_max_body_size 25M;

    location /pwa/ {
        alias $APP_DIR/pwa/;
        expires 7d;
        access_log off;
    }

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

        proxy_set_header Accept-Encoding "";
        sub_filter '</head>' '$INJECT';
        sub_filter_once on;
    }
}
EOF

if nginx -t; then
    systemctl reload nginx
    echo ""
    echo "SUCCESS: ToyLab home-screen icon is now live."
else
    echo "Config test FAILED — restoring previous config."
    cp "$BACKUP" "$CONF"
    nginx -t && systemctl reload nginx
    exit 1
fi
