from kafka import KafkaAdminClient, KafkaProducer, KafkaConsumer
from kafka.admin import NewTopic
import time


CONFIGURATIONS = [
    {"batch_size": 1, "compression": "none", "producer_mode": "sync", "commit_mode": "sync", "partitions": 1},
    {"batch_size": 1000, "compression": "gzip", "producer_mode": "async", "commit_mode": "async", "partitions": 4},
    {"batch_size": 2000, "compression": "snappy", "producer_mode": "async", "commit_mode": "sync", "partitions": 4},
    {"batch_size": 2000, "compression": "lz4", "producer_mode": "fire_and_forget", "commit_mode": "async", "partitions": 4},
    {"batch_size": 10000, "compression": "zstd", "producer_mode": "async", "commit_mode": "sync", "partitions": 8},
    {"batch_size": 20000, "compression": "none", "producer_mode": "fire_and_forget", "commit_mode": "async", "partitions": 8},
    {"batch_size": 100, "compression": "gzip", "producer_mode": "sync", "commit_mode": "sync", "partitions": 1},
    {"batch_size": 15000, "compression": "lz4", "producer_mode": "async", "commit_mode": "async", "partitions": 8},
    {"batch_size": 5000, "compression": "zstd", "producer_mode": "fire_and_forget", "commit_mode": "sync", "partitions": 4},
    {"batch_size": 20000, "compression": "snappy", "producer_mode": "combination", "commit_mode": "async", "partitions": 8},
]

BROKER = "localhost:9092"
TOPIC_PREFIX = "test-topic-"
MESSAGE_COUNT = 10000


def create_topic(topic_name, partitions):
    admin_client = KafkaAdminClient(bootstrap_servers=BROKER)
    topic = NewTopic(name=topic_name, num_partitions=partitions, replication_factor=1)
    try:
        admin_client.create_topics([topic])
        print(f"Created topic: {topic_name}")
    except Exception as e:
        print(f"Error creating topic {topic_name}: {e}")
    finally:
        admin_client.close()


def produce_messages(topic, batch_size, compression_type, mode):
    producer = KafkaProducer(
        bootstrap_servers=BROKER,
        compression_type=None if compression_type == "none" else compression_type,
        batch_size=batch_size,
        linger_ms=50,
    )
    message = b"Test Message" * 10
    start_time = time.time()

    def sync_produce():
        for _ in range(MESSAGE_COUNT):
            producer.send(topic, value=message).get()

    def async_produce():
        for _ in range(MESSAGE_COUNT):
            producer.send(topic, value=message)

    if mode == "sync":
        sync_produce()
    elif mode == "async":
        async_produce()
    elif mode == "fire_and_forget":
        for _ in range(MESSAGE_COUNT):
            producer.send(topic, value=message)
    elif mode == "combination":
        for i in range(MESSAGE_COUNT):
            if i % 10 == 0:
                producer.send(topic, value=message).get()
            else:
                producer.send(topic, value=message)

    producer.flush()
    elapsed_time = time.time() - start_time
    producer.close()
    print(f"Produced {MESSAGE_COUNT} messages in {elapsed_time:.2f} seconds.")
    return elapsed_time


def consume_messages(topic, partitions, commit_mode):
    consumer = KafkaConsumer(
        topic,
        bootstrap_servers=BROKER,
        auto_offset_reset="earliest",
        enable_auto_commit=(commit_mode == "async"),
        group_id="test-group"
    )
    start_time = time.time()
    message_count = 0

    try:
        for message in consumer:
            message_count += 1
            if message_count >= MESSAGE_COUNT:
                break
            if commit_mode == "sync" and message_count % 100 == 0:
                consumer.commit()
    finally:
        elapsed_time = time.time() - start_time
        consumer.close()
        print(f"Consumed {message_count} messages in {elapsed_time:.2f} seconds.")
    return elapsed_time


def run_configuration(config, config_id):
    topic_name = f"{TOPIC_PREFIX}{config_id}"
    print(f"\nRunning Configuration {config_id}: {config}")

    create_topic(topic_name, config["partitions"])

    producer_time = produce_messages(
        topic_name,
        batch_size=config["batch_size"],
        compression_type=config["compression"],
        mode=config["producer_mode"],
    )

    consumer_time = consume_messages(
        topic_name,
        partitions=config["partitions"],
        commit_mode=config["commit_mode"],
    )

    throughput_producer = MESSAGE_COUNT / producer_time
    throughput_consumer = MESSAGE_COUNT / consumer_time
    print(f"Config {config_id}: Producer Throughput: {throughput_producer:.2f} msg/s")
    print(f"Config {config_id}: Consumer Throughput: {throughput_consumer:.2f} msg/s")


if __name__ == "__main__":
    for idx, config in enumerate(CONFIGURATIONS):
        run_configuration(config, idx + 1)
