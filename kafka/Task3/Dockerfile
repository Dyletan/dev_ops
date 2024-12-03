# Use the Kafka KRaft mode image as the base image
FROM confluentinc/cp-kafka:7.4.0

CMD ["/bin/sh", "-c", "/usr/bin/kafka-storage format -t $(/usr/bin/kafka-storage random-uuid) -c /etc/kafka/kraft/server.properties && /usr/bin/kafka-server-start /etc/kafka/kraft/server.properties"]

# kafka-topics --bootstrap-server localhost:9092 --create --topic test --partitions 1
# kafka-console-producer --bootstrap-server localhost:9092 --topic test
# kafka-console-consumer --bootstrap-server localhost:9092 --topic test --from-beginning