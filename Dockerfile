FROM alpine:latest

ADD build.sh /opt/build.sh

RUN apk update \
 && apk upgrade \
 && apk add --no-cache ca-certificates curl wget tar grep sed busybox \
 && chmod +x /opt/build.sh

CMD "/opt/build.sh"
