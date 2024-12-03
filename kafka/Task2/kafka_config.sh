#!bin/bash

server_file_path="./kafka_2.13-3.9.0/config/server.properties"
consumer_file_path="./kafka_2.13-3.9.0/config/consumer.properties"
producer_file_path="./kafka_2.13-3.9.0/config/producer.properties"

search_text=$(echo "PLAINTEXT://:9092" | sed 's/\//\\\//g')
replaced_text=$(echo "SASL_PLAINTEXT://localhost:9092"| sed 's/\//\\\//g')

if [ -f "$server_file_path" ]; then
    awk '{gsub(/PLAINTEXT:\/\/:9092/,"SASL_PLAINTEXT://localhost:9092")}1' "$server_file_path" > temp && mv temp "$server_file_path"
    echo "Replaced in $server_file_path"
else
    echo "File $server_file_path does not exist."
fi

bash -c "cat <<EOF >> $server_file_path

security.inter.broker.protocol=SASL_PLAINTEXT
sasl.mechanism.inter.broker.protocol=PLAIN
sasl.enabled.mechanisms=PLAIN
EOF"

bash -c "cat <<EOF >> $producer_file_path

sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="alice"   password="alice-secret";  
security.protocol=SASL_PLAINTEXT  
sasl.mechanism=PLAIN
EOF"

bash -c "cat <<EOF >> $consumer_file_path

sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="alice"   password="alice-secret";  
security.protocol=SASL_PLAINTEXT  
sasl.mechanism=PLAIN
EOF"