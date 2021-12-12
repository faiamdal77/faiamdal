#!/bin/sh

# Global variables
DIR_TMP="$(mktemp -d)"
DIR_XRAY="/usr/local/bin/xray"

# Set all V2Ray or Xray
curl -sL -o ${DIR_TMP}/Xray-linux-64.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
install -d ${DIR_TMP}/xray;install -d ${DIR_XRAY}
busybox unzip ${DIR_TMP}/Xray-linux-64.zip -d ${DIR_TMP}/xray
install -m 755 ${DIR_TMP}/xray/* ${DIR_XRAY}

rm -rf ${DIR_TMP}

install -d /etc/xray
cat <<EOF> /etc/xray/config.json
{
    "inbounds": [
        {
            "listen": "/etc/caddy/vless",
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "${APP_ID}"
                    }
                ],
                "decryption": "none"
                #"fallbacks": [{}]
            },
            "streamSettings": {
                "network": "ws",
                "security": "none",
                "wsSettings": {
                	"path": "/bing.com"
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "tag": "direct"
        },
        {
            "protocol": "blackhole",
            "tag": "reject"
        }
    ]
    #"routing": {}
}
EOF
sed -i "1c :$PORT" /etc/caddy/Caddyfile
# Run V2Ray or Xray
${DIR_XRAY}/xray -c /etc/xray/config.json &
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
