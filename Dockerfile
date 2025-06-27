FROM alpine:latest

RUN apk add --no-cache \
    curl \
    netcat-openbsd \
    nmap \
    mosquitto-clients \
    bind-tools \
    iputils \
    tcpdump \
    iperf3 \
    traceroute

WORKDIR /workspace
ENTRYPOINT ["sh"]
