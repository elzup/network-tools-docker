FROM alpine:3.20

RUN apk add --no-cache \
    curl \
    wget \
    netcat-openbsd \
    socat \
    nmap \
    mosquitto-clients \
    websocat \
    bind-tools \
    whois \
    iputils \
    tcpdump \
    iperf3 \
    traceroute \
    mtr \
    iproute2 \
    net-tools \
    ethtool \
    bridge \
    openssl \
    jq

WORKDIR /workspace
ENTRYPOINT ["sh"]
