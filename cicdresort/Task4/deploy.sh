ssh root@167.99.244.46 'mkdir -p /tmp/scripts/nexus'
scp nexus_install.sh setup_repo.sh root@167.99.244.46:/tmp/scripts/nexus
ssh root@167.99.244.46 << 'EOF'
cd /tmp/scripts/nexus
chmod +x nexus_install.sh setup_repo.sh
./nexus_install.sh
EOF

echo "Waiting for nexus to start up:"
sleep 15
echo "Your password"
ssh root@167.99.244.46 'cat /opt/nexus/sonatype-work/nexus3/admin.password'

echo "Now follow to http://167.99.244.46:8081 and set up a devops123 password"
echo "After that you should: 
ssh root@167.99.244.46
cd /tmp/scripts/nexus
./setup_repo.sh
"