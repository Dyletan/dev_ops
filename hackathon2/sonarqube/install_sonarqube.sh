#!/bin/sh

# Update the package list
sudo apt update

# Install dependencies
sudo apt install -y openjdk-17-jdk unzip wget

# Download and install SonarQube
SONARQUBE_VERSION="9.9.1.69595"  # Adjust version as needed
SONARQUBE_DIR="/opt/sonarqube/sonar"
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-$SONARQUBE_VERSION.zip -O /tmp/sonarqube.zip
sudo unzip /tmp/sonarqube.zip -d /opt/sonarqube
sudo mv /opt/sonarqube/sonarqube-$SONARQUBE_VERSION $SONARQUBE_DIR
sudo rm /tmp/sonarqube.zip

# Set permissions for SonarQube
sudo groupadd -f sonar
sudo useradd -g sonar -d $SONARQUBE_DIR sonar
sudo chown -R sonar:sonar $SONARQUBE_DIR

# Create a SonarQube systemd service file
sudo tee /etc/systemd/system/sonarqube.service > /dev/null <<EOF
[Unit]
Description=SonarQube service
After=network.target

[Service]
Type=forking
ExecStart=$SONARQUBE_DIR/bin/linux-x86-64/sonar.sh start
ExecStop=$SONARQUBE_DIR/bin/linux-x86-64/sonar.sh stop
User=sonar
Group=sonar
Environment="JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64"
Restart=on-failure
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable, and start SonarQube service
sudo systemctl daemon-reload
sudo systemctl enable sonarqube.service
sudo systemctl start sonarqube.service

# Check SonarQube status
sudo systemctl status sonarqube.service

