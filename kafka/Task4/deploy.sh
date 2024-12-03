ssh root@167.99.244.46 'mkdir -p /tmp/scripts/kafka'
scp deploy_kafka.sh setup_auth.sh root@167.99.244.46:/tmp/scripts/kafka
ssh root@167.99.244.46 << 'EOF'
cd /tmp/scripts/kafka
chmod +x deploy_kafka.sh setup_auth.sh
./deploy_kafka.sh
echo "You can see the kafka ui at http://167.99.244.46:8080"
EOF
echo ""
echo "Use these commands to set up an authenticator for ACL permissions:
cd /tmp/scripts/kafka
./setup_auth.sh"
echo ""
ssh root@167.99.244.46