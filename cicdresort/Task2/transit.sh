#!/bin/bash

SERVER_IP=167.99.244.46

# Error handler
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

# Step 1: Check if Transit Vault server is running on port 8200
echo "Step 1: Installing Transit Vault server..."
if ! curl -s http://${SERVER_IP}:8200/v1/sys/health | grep -q "initialized"; then
    ./install_vault.sh transit
else
    echo "Transit Vault server is already running."
fi

# Set environment variables
export VAULT_ADDR="http://${SERVER_IP}:8200"
export VAULT_TOKEN=$(cat /root/.transit-token)

# Step 2: Enable Transit secrets engine if not already enabled
echo "Step 2: Configuring Transit secrets engine..."
if ! vault secrets list | grep -q 'transit/'; then
    vault secrets enable transit
else
    echo "Transit secrets engine is already enabled."
fi

# Ensure the encryption key for auto-unseal exists
if ! vault list transit/keys | grep -q 'autounseal'; then
    vault write -f transit/keys/autounseal
else
    echo "Auto-unseal encryption key already exists."
fi

# Step 3: Check and create the auto-unseal policy if it doesn't exist
if ! vault policy list | grep -q 'autounseal'; then
    vault policy write autounseal -<< EOF
path "transit/encrypt/autounseal" {
   capabilities = [ "create", "update" ]
}

path "transit/decrypt/autounseal" {
   capabilities = [ "create", "update" ]
}
EOF
else
    echo "Auto-unseal policy already exists."
fi

# Step 4: Generate the wrapped token only if wrapping-token.txt doesn't exist
# Check if the wrapping token is valid; regenerate if invalid or expired
if ! vault unwrap -field=token $(cat /root/wrapping-token.txt) &>/dev/null; then
    echo "Generating a new wrapping token..."
    vault token create -orphan -policy="autounseal" -wrap-ttl=120 -period=24h -field=wrapping_token > /root/wrapping-token.txt
else
    echo "Wrapping token already exists in wrapping-token.txt."
fi

export VAULT_ADDR="http://${SERVER_IP}:8100"
export VAULT_TOKEN=$(cat /root/.vault-token)
# Step 5: Check if Primary Vault server is running on port 8100
echo "Step 3: Installing primary Vault server with auto-unseal..."
if ! curl -s http://${SERVER_IP}:8100/v1/sys/health | grep -q "initialized"; then
    ./install_vault.sh primary
else
    echo "Primary Vault server is already running."
fi

# Step 6: Setup auto-unseal for transit vault for the case
# if the transit vault will be restarted
echo "Creating unseal script for Transit Vault..."
cat > /usr/local/bin/unseal_transit.sh << 'EOF'
#!/bin/bash
export VAULT_ADDR="http://${SERVER_IP}:8200"
KEYS_FILE="/root/.transit-keys"

if [[ -f "$KEYS_FILE" ]]; then
    for key in $(cat "$KEYS_FILE"); do
        vault operator unseal "$key"
    done
    echo "Transit Vault unsealed."
else
    echo "Unseal keys file not found."
    exit 1
fi
EOF

chmod +x /usr/local/bin/unseal_transit.sh

# creating the service that will trigger after the transit-vault
# service and unseal it
if [ ! -f "/etc/systemd/system/unseal-transit.service" ]; then
    cat > /etc/systemd/system/unseal-transit.service << EOF
[Unit]
Description=Unseal Transit Vault
After=transit-vault.service
Requires=transit-vault.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/unseal_transit.sh

[Install]
WantedBy=transit-vault.service
EOF
chmod 644 /etc/systemd/system/unseal-transit.service
systemctl daemon-reload
systemctl enable unseal-transit
fi

echo "Transit auto-unseal setup completed successfully!"
echo "Transit Vault is running on http://${SERVER_IP}:8200"
echo "You can login using Transit Server Root Token: /root/.transit-token"
echo "Primary Vault is running on http://${SERVER_IP}:8100"
echo "You can login using Transit Server Root Token: /root/.vault-token"
echo ""

echo "To test auto-unseal:"
echo "1. Stop the primary Vault: systemctl stop vault"
echo "2. Start the primary Vault: systemctl start vault"
echo "3. Check status: VAULT_ADDR=http://${SERVER_IP}:8100 vault status"