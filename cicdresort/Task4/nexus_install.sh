#!/bin/bash

# Variables
NEXUS_HOME="/opt/nexus"
NEXUS_FILE="${NEXUS_HOME}/bin/nexus"
NEXUS_USER="nexus"
NEXUS_GROUP="nexus"
NEXUS_PORT="8081"
SERVER_IP=167.99.244.46
JAVA_8_PATH="/usr/lib/jvm/java-8-openjdk-amd64"
ADMIN_PASSWORD_FILE="${NEXUS_HOME}/sonatype-work/nexus3/admin.password"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    log "Please run as root"
    exit 1
fi

# Install prerequisites
echo "Installing prerequisites..."
apt-get update
apt-get install -y openjdk-8-jdk wget

# Create nexus user if it doesn't exist
if ! id "$NEXUS_USER" &>/dev/null; then
    echo "Creating nexus user..."
    adduser --disabled-login --no-create-home --gecos "" "$NEXUS_USER"
fi

# Download and extract Nexus if not already present
if [ ! -d "$NEXUS_HOME" ]; then
    echo "Downloading and extracting Nexus..."
    cd /opt
    wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz
    tar -zxvf latest-unix.tar.gz
    mv /opt/nexus-*/ /opt/nexus
    rm -f latest-unix.tar.gz
    
    # Set permissions
    chown -R "$NEXUS_USER:$NEXUS_GROUP" "$NEXUS_HOME" /opt/sonatype-work
    
    echo "run_as_user=\"$NEXUS_USER\"" > /opt/nexus/bin/nexus.rc
fi

# Configure Nexus properties
echo "Configuring Nexus properties..."

if [[ -f "$NEXUS_FILE" ]]; then
    sudo sed -i 's|^# *INSTALL4J_JAVA_HOME_OVERRIDE=.*|INSTALL4J_JAVA_HOME_OVERRIDE="'"$JAVA_8_PATH"'"|' "$NEXUS_FILE"
    echo "Updated INSTALL4J_JAVA_HOME_OVERRIDE in $NEXUS_FILE"
else
    echo "Error: File $NEXUS_FILE does not exist."
    exit 1
fi

cat > "$NEXUS_HOME/bin/nexus.vmoptions" << EOF
-Xms512m
-Xmx512m
-XX:MaxDirectMemorySize=512m
-XX:LogFile=./sonatype-work/nexus3/log/jvm.log
-XX:-OmitStackTraceInFastThrow
-Djava.net.preferIPv4Stack=true
-Dkaraf.home=.
-Dkaraf.base=.
-Dkaraf.etc=etc/karaf
-Djava.util.logging.config.file=/etc/karaf/java.util.logging.properties
-Dkaraf.data=./sonatype-work/nexus3
-Dkaraf.log=./sonatype-work/nexus3/log
-Djava.io.tmpdir=./sonatype-work/nexus3/tmp
EOF

# Create systemd service file
echo "Configuring systemd service..."
cat > "/etc/systemd/system/nexus.service" << EOF
[Unit]
Description=Nexus Service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=${NEXUS_FILE} start
ExecStop=${NEXUS_FILE} stop
User=${NEXUS_USER}
Restart=on-abort
TimeoutSec=600

[Install]
WantedBy=multi-user.target
EOF

# Set correct permissions
chmod 644 /etc/systemd/system/nexus.service

echo "Starting Nexus service..."
systemctl daemon-reload
systemctl enable nexus.service
systemctl start nexus.service

echo "Check service logs"
tail -f /opt/sonatype-work/nexus3/log/nexus.log

echo "Nexus installation completed successfully!"
echo "Default admin password can be found at: ${ADMIN_PASSWORD_FILE}"
echo "Access Nexus at: http://${SERVER_IP}:${NEXUS_PORT}"