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
            "listen": "/etc/caddy/vmess",
            "protocol": "vmess",
            "settings": {
                "clients": [
                    {
                        "id": "${APP_ID}",
                        "alterId": 27
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "ws",
                "wsSettings": {
                	"path": "/$APP_PATH_vmess"
                }
            }
        },
        {
            "listen": "/etc/caddy/vless","protocol": "vless",
            "settings": {"clients": [{"id": "${APP_ID}"}],"decryption": "none"},
            "streamSettings": {"network": "ws","wsSettings": {"path": "/$APP_PATH_vless"}}
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
cat /etc/caddy/Caddyfile
echo "/\$APP_PATH_vmess"
sed -i "1c :$PORT" /etc/caddy/Caddyfile
sed -i "s/\$APP_PATH/$APP_PATH/g" /etc/caddy/Caddyfile
cat /etc/caddy/Caddyfile
# Run V2Ray or Xray
${DIR_XRAY}/xray -c /etc/xray/config.json &
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
