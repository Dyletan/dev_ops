#!/bin/bash

echo "Stopping existing containers..."
containers=("broker01" "broker02" "broker03" "zookeeper" "kafka-ui")

for container in "${containers[@]}"; do
    docker stop "$container" 2>/dev/null || true
    docker rm "$container" 2>/dev/null || true
done

for port in 9092 9093 9094 2181 29092 29093 29094; do
    pid=$(lsof -t -i:$port) || true
    if [ ! -z "$pid" ]; then
        echo "Killing process using port $port"
        kill -9 $pid
    fi
done

# Create deployment directory
cd /tmp/scripts/kafka

# Create modified docker-compose.yml
cat << 'EOF' > docker-compose.yml
version: '3.8'
services:
  zookeeper:
    image: bitnami/zookeeper:latest
    container_name: zookeeper
    environment:
      - ALLOW_ANONYMOUS_LOGIN=yes
    ports:
      - "2181:2181"

  broker01:
    image: bitnami/kafka:latest
    container_name: broker01
    depends_on:
      - zookeeper
    ports:
      - "9092:9092"
      - "29092:29092"
    environment:
      - KAFKA_BROKER_ID=1
      - KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181
      - ALLOW_PLAINTEXT_LISTENER=yes
      - KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=PLAINTEXT:PLAINTEXT,EXTERNAL:PLAINTEXT
      - KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://broker01:9092,EXTERNAL://167.99.244.46:29092
      - KAFKA_LISTENERS=PLAINTEXT://0.0.0.0:9092,EXTERNAL://0.0.0.0:29092
      - KAFKA_INTER_BROKER_LISTENER_NAME=PLAINTEXT
    user: "0:0"
  broker02:
    image: bitnami/kafka:latest
    container_name: broker02
    depends_on:
      - zookeeper
    ports:
      - "9093:9093"
      - "29093:29093"
    environment:
      - KAFKA_BROKER_ID=2
      - KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181
      - ALLOW_PLAINTEXT_LISTENER=yes
      - KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=PLAINTEXT:PLAINTEXT,EXTERNAL:PLAINTEXT
      - KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://broker02:9093,EXTERNAL://167.99.244.46:29093
      - KAFKA_LISTENERS=PLAINTEXT://0.0.0.0:9093,EXTERNAL://0.0.0.0:29093
      - KAFKA_INTER_BROKER_LISTENER_NAME=PLAINTEXT
    user: "0:0"
  broker03:
    image: bitnami/kafka:latest
    container_name: broker03
    depends_on:
      - zookeeper
    ports:
      - "9094:9094"
      - "29094:29094"
    environment:
      - KAFKA_BROKER_ID=3
      - KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181
      - ALLOW_PLAINTEXT_LISTENER=yes
      - KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=PLAINTEXT:PLAINTEXT,EXTERNAL:PLAINTEXT
      - KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://broker03:9094,EXTERNAL://167.99.244.46:29094
      - KAFKA_LISTENERS=PLAINTEXT://0.0.0.0:9094,EXTERNAL://0.0.0.0:29094
      - KAFKA_INTER_BROKER_LISTENER_NAME=PLAINTEXT
    user: "0:0"
  kafka-ui:
    image: provectuslabs/kafka-ui:latest
    container_name: kafka-ui
    depends_on:
      - broker01
      - broker02
      - broker03
    ports:
      - "8080:8080"
    environment:
      - KAFKA_CLUSTERS_0_NAME=local-cluster
      - KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS=broker01:9092,broker02:9093,broker03:9094
    user: "0:0"
EOF

# Install Docker if not already installed
if ! command -v docker &> /dev/null; then
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update
    apt-get install -y docker-ce
fi

# Install Docker Compose if not already installed
if ! command -v docker-compose &> /dev/null; then
    curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# Start the Kafka cluster
docker-compose up -d

# Check the status
docker-compose ps