ssh root@167.99.244.46 'mkdir -p /tmp/scripts/vault'
scp install_vault.sh transit.sh root@167.99.244.46:/tmp/scripts/vault
ssh root@167.99.244.46 << 'EOF'
cd /tmp/scripts/vault
chmod +x install_vault.sh transit.sh
./transit.sh
echo "Use the below token to login to Primary Vault http://167.99.244.46:8100"
cat /root/.vault-token
EOF