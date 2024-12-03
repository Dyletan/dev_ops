#!/bin/bash

VAULT_VERSION="1.18.0"
VAULT_DIR="/usr/local/bin"
SERVER_IP=167.99.244.46

if [[ "$1" == "transit" ]]; then
    VAULT_CONFIG_DIR="/etc/transit-vault.d"
    VAULT_DATA_DIR="/opt/transit-vault/data"
    VAULT_LOGS_DIR="/var/log/transit-vault"
    VAULT_USER="transit-vault"
    VAULT_GROUP="transit-vault"
    KEYS_FILE="/root/.transit-keys"
    ROOT_TOKEN_FILE="/root/.transit-token"
    VAULT_PORT=8200
    VAULT_API_ADDR="http://${SERVER_IP}:$VAULT_PORT"
    VAULT_CLUSTER_ADDR="http://${SERVER_IP}:$((VAULT_PORT+1))"
    VAULT_SERVICE="transit-vault"
    SEAL_CONFIG=""
else
    VAULT_CONFIG_DIR="/etc/vault.d"
    VAULT_DATA_DIR="/opt/vault/data"
    VAULT_LOGS_DIR="/var/log/vault"
    VAULT_USER="vault"
    VAULT_GROUP="vault"
    KEYS_FILE="/root/.vault-keys"
    ROOT_TOKEN_FILE="/root/.vault-token"
    VAULT_PORT=8100
    VAULT_API_ADDR="http://${SERVER_IP}:$VAULT_PORT"
    VAULT_CLUSTER_ADDR="http://${SERVER_IP}:$((VAULT_PORT+1))"
    VAULT_SERVICE="vault"
    if [[ -f "wrapping-token.txt" ]]; then
        SEAL_CONFIG="seal \"transit\" {
    address = \"http://${SERVER_IP}:8200\"
    token = \"$(vault unwrap -field=token $(cat wrapping-token.txt))\"
    disable_renewal = \"false\"
    key_name = \"autounseal\"
    mount_path = \"transit/\"
}"
    else
        SEAL_CONFIG=""
    fi
fi

error_handler() {
    local parent_lineno="$1"
    local message="$2"
    local code="${3:-1}"
    if [[ -n "$message" ]] ; then
        echo "Error on or near line ${parent_lineno}: ${message}; exiting with status ${code}"
    else
        echo "Error on or near line ${parent_lineno}; exiting with status ${code}"
    fi
    exit "${code}"
}
trap 'error_handler ${LINENO}' ERR

# Check if root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

# Create user and group
if ! getent group ${VAULT_GROUP} >/dev/null; then
    groupadd --system ${VAULT_GROUP}
fi
if ! id "${VAULT_USER}" &>/dev/null; then
    useradd --system -g ${VAULT_GROUP} -d "/opt/${VAULT_USER}" -s /sbin/nologin ${VAULT_USER}
fi

# Install dependencies and Vault
if ! command -v vault >/dev/null 2>&1; then
    apt-get update
    apt-get install -y curl unzip jq

    # Determine architecture
    ARCHITECTURE=$(uname -m)
    if [ "$ARCHITECTURE" = "x86_64" ]; then
        VAULT_ARCHITECTURE="amd64"
    elif [[ "$ARCHITECTURE" == "aarch64" ]]; then
        VAULT_ARCHITECTURE="arm64"
    else
        echo "Unsupported architecture: $ARCHITECTURE"
        exit 1
    fi

    # Download and install Vault
    curl -O "https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_${VAULT_ARCHITECTURE}.zip"
    unzip "vault_${VAULT_VERSION}_linux_${VAULT_ARCHITECTURE}.zip"
    rm "vault_${VAULT_VERSION}_linux_${VAULT_ARCHITECTURE}.zip"
    mv vault ${VAULT_DIR}
    chmod 755 ${VAULT_DIR}/vault
fi

# Create directories
mkdir -p ${VAULT_CONFIG_DIR} ${VAULT_DATA_DIR} ${VAULT_LOGS_DIR}
chmod 750 ${VAULT_CONFIG_DIR} ${VAULT_DATA_DIR} ${VAULT_LOGS_DIR}
chown -R ${VAULT_USER}:${VAULT_GROUP} ${VAULT_CONFIG_DIR} ${VAULT_DATA_DIR} ${VAULT_LOGS_DIR}

# Create Vault configuration
if [ ! -f "${VAULT_CONFIG_DIR}/vault.hcl" ]; then
    cat > ${VAULT_CONFIG_DIR}/vault.hcl << EOF
ui            = true
cluster_addr  = "${VAULT_CLUSTER_ADDR}"
api_addr      = "${VAULT_API_ADDR}"

storage "file" {
    path = "${VAULT_DATA_DIR}"
}

listener "tcp" {
  address     = "0.0.0.0:${VAULT_PORT}"
  tls_disable = "true"
}

${SEAL_CONFIG}
EOF

    chmod 640 ${VAULT_CONFIG_DIR}/vault.hcl
    chown ${VAULT_USER}:${VAULT_GROUP} ${VAULT_CONFIG_DIR}/vault.hcl
fi

# Create systemd service
if [ ! -f "/etc/systemd/system/${VAULT_SERVICE}.service" ]; then
    cat > /etc/systemd/system/${VAULT_SERVICE}.service << EOF
[Unit]
Description="HashiCorp Vault - A tool for managing secrets"
Documentation=https://developer.hashicorp.com/vault/docs
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=${VAULT_CONFIG_DIR}/vault.hcl
StartLimitIntervalSec=60
StartLimitBurst=3

[Service]
Type=notify
User=${VAULT_USER}
Group=${VAULT_GROUP}
ProtectSystem=full
ProtectHome=read-only
PrivateTmp=yes
PrivateDevices=yes
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=${VAULT_DIR}/vault server -config=${VAULT_CONFIG_DIR}/vault.hcl
ExecReload=/bin/kill --signal HUP \$MAINPID
KillMode=process
KillSignal=SIGINT
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
LimitNOFILE=65536
LimitMEMLOCK=infinity
LimitCORE=0

[Install]
WantedBy=multi-user.target
EOF

chmod 644 /etc/systemd/system/${VAULT_SERVICE}.service
    systemctl daemon-reload
    systemctl enable ${VAULT_SERVICE}
    systemctl start ${VAULT_SERVICE}
    sleep 5
fi

# VAULT_ADDR tells the vault CLI which Vault server to connect to
# it is used by the vault CLI command automatically
export VAULT_ADDR="${VAULT_API_ADDR}"

if ! vault status 2>/dev/null | grep -q "Initialized.*true"; then
    vault_init=$(vault operator init -format=json)
    echo "${vault_init}" | jq -r '.root_token' > ${ROOT_TOKEN_FILE}
    echo "${vault_init}" | jq -r '.unseal_keys_b64[]' > ${KEYS_FILE}
    chmod 600 ${ROOT_TOKEN_FILE} ${KEYS_FILE}

    # Unseal Vault using the keys
    for key in $(cat ${KEYS_FILE}); do
        vault operator unseal ${key}
    done
fi

echo "Vault is running on port ${VAULT_PORT}"
echo "You can login using this Vault Token: ${ROOT_TOKEN_FILE}"
echo "Check Vault at http:/${SERVER_IP}:${VAULT_PORT}"
echo ""