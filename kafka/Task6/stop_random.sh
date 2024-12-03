#!/bin/bash

stop_random_broker() {
  brokers=("broker01" "broker02" "broker03")
  random_broker=${brokers[$RANDOM % ${#brokers[@]}]}
  echo "Stopping $random_broker"
  docker-compose stop $random_broker
  sleep 120
  echo "Starting $random_broker"
  docker-compose start $random_broker
}

send_messages() {
  topics=("topic1" "topic2" "topic3") # Add your topics here
  for topic in "${topics[@]}"; do
    echo "Sending message to $topic"
    docker-compose exec broker01 kafka-console-producer.sh --broker-list broker01:9092,broker02:9093,broker03:9094 --topic $topic <<< "Test message at $(date)"
  done
}

while true; do
  stop_random_broker
  send_messages
  sleep 900 # 15 minutes
done
