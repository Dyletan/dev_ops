# Create network
docker network create kafka_network

# Start Zookeeper
docker run -d --name zookeeper --network kafka_network -p 2181:2181 -e ALLOW_ANONYMOUS_LOGIN=yes bitnami/zookeeper:latest

# Start Kafka brokers
for i in 1 2 3; do
  port=$((9090 + i))
  docker run -d \
    --name broker0$i \
    --network kafka_network \
    -p $port:$port \
    -e KAFKA_BROKER_ID=$i \
    -e KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181 \
    -e ALLOW_PLAINTEXT_LISTENER=yes \
    -e KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=PLAINTEXT:PLAINTEXT \
    -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://broker0$i:$port \
    -e KAFKA_LISTENERS=PLAINTEXT://0.0.0.0:$port \
    bitnami/kafka:latest
done
