#!/bin/bash

SITE_NAME="devopsila"
LOCAL_IP="127.0.0.1"
PORT="8080"

if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

if ! grep -q "^${LOCAL_IP}\s*${SITE_NAME}$" /etc/hosts; then
    echo "${LOCAL_IP} ${SITE_NAME}" >> /etc/hosts
    echo "Added ${SITE_NAME} to /etc/hosts"
fi

iptables -t nat -D PREROUTING -p tcp --dport 80 -j REDIRECT --to-port ${PORT} 2>/dev/null
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port ${PORT}

iptables -t nat -D OUTPUT -p tcp -d localhost --dport 80 -j REDIRECT --to-port ${PORT} 2>/dev/null
iptables -t nat -A OUTPUT -p tcp -d localhost --dport 80 -j REDIRECT --to-port ${PORT}

echo "Configuration completed. You can now access your service at http://${SITE_NAME}"
