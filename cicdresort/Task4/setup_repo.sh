#!/bin/bash

NEXUS_PORT="8081"
DOCKER_PORT="8083"
SERVER_IP="167.99.244.46"

read -sp "Enter Nexus admin password: " admin_password
echo ""

if [ -z "$admin_password" ]; then
    echo "Error: No password provided." >&2
    exit 1
fi

setup_docker_repository() {
    echo "Setting up Docker repository as a group replacement with hosted repository..."
    
    curl -X POST "http://${SERVER_IP}:${NEXUS_PORT}/service/rest/v1/repositories/docker/hosted" \
        -H "accept: application/json" \
        -H "Content-Type: application/json" \
        -u "admin:${admin_password}" \
        -d '{
          "name": "docker-hosted",
          "online": true,
          "storage": {
            "blobStoreName": "default",
            "strictContentTypeValidation": true,
            "writePolicy": "ALLOW"
          },
          "cleanup": {
            "policyNames": []
          },
          "docker": {
            "v1Enabled": false,
            "forceBasicAuth": true,
            "httpPort": '"${DOCKER_PORT}"'
          }
        }'

    if [ $? -eq 0 ]; then
        echo "Docker hosted repository (acting as group) created successfully."
    else
        echo "Failed to create Docker hosted repository. Check Nexus configuration and try again."
        exit 1
    fi
}

install_docker() {
    echo "Installing Docker..."
    # Update package lists
    apt-get update

    # Install required packages
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    # Add Docker's official GPG key
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    # Set up the Docker repository
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Update package lists again
    apt-get update

    # Install Docker
    apt-get install -y docker-ce docker-ce-cli containerd.io

    # Start and enable Docker service
    systemctl start docker
    systemctl enable docker

    echo "Docker installed successfully"
}

echo "Starting Docker repository configuration..."
setup_docker_repository

echo "Docker repository setup completed!"
echo "Docker repository is available at: http://${SERVER_IP}:${DOCKER_PORT}"

if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker..."
    install_docker
fi

mkdir -p /etc/docker

echo "Updating Docker configuration..."
if [ ! -f /etc/docker/daemon.json ]; then
    echo '{}' | sudo tee /etc/docker/daemon.json > /dev/null
fi

# Backup existing configuration
cp /etc/docker/daemon.json /etc/docker/daemon.json.backup

if ! command -v jq &> /dev/null; then
    echo "jq not found. Installing jq..."
    apt-get update && apt-get install -y jq
fi

# Update Docker configuration
echo "Configuring Docker insecure registry..."
sudo jq --arg port "${DOCKER_PORT}" '.["insecure-registries"] += ["'"${SERVER_IP}:${DOCKER_PORT}"'"]' /etc/docker/daemon.json > /etc/docker/daemon.json.tmp
sudo mv /etc/docker/daemon.json.tmp /etc/docker/daemon.json

echo "Docker configuration updated."

# Restart Docker daemon
echo "Restarting Docker daemon..."
if ! systemctl restart docker; then
    echo "Failed to restart Docker. Please check the system." >&2
    exit 1
fi
