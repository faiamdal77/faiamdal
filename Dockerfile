FROM alpine:latest

RUN mkdir -p /etc/caddy \
 && install -d /usr/share/caddy

ADD Caddyfile /etc/caddy/Caddyfile
ADD build.sh /opt/build.sh

RUN apk update \
 && apk upgrade \
 && apk add --no-cache ca-certificates curl wget tar grep sed busybox caddy \
 && chmod +x /opt/build.sh \
 && chmod +x /etc/caddy/Caddyfile

CMD "/opt/build.sh"
