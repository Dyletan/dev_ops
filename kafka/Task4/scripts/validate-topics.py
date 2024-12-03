import yaml
import os
import sys
from kafka.admin import KafkaAdminClient, NewTopic
from kafka.errors import KafkaError

def validate_topic_config(config, admin_client):
    if 'delete' in config and config['delete']:
        # Validate deletion case
        if 'name' not in config:
            raise ValueError("Topic name is required for deletion")
        
        # Check if the topic exists in the cluster
        existing_topics = admin_client.list_topics()
        if config['name'] not in existing_topics:
            raise ValueError(f"Topic {config['name']} does not exist and cannot be deleted")
    else:
        # Regular validation for creation or modification
        required_fields = ['name', 'partitions', 'replication_factor']
        for field in required_fields:
            if field not in config:
                raise ValueError(f"Missing required field: {field}")
        
        if not isinstance(config['partitions'], int) or config['partitions'] <= 0:
            raise ValueError("Partitions must be a positive integer")
        
        if not isinstance(config['replication_factor'], int) or config['replication_factor'] <= 0:
            raise ValueError("Replication factor must be a positive integer")
        
        cluster_metadata = admin_client.describe_cluster()
        broker_count = len(cluster_metadata['brokers'])
        if config['replication_factor'] > broker_count:
            raise ValueError(f"Replication factor {config['replication_factor']} exceeds number of brokers ({broker_count})")

        if 'configs' in config:
            valid_cleanup_policies = ['delete', 'compact', 'compact,delete']
            cleanup_policy = config['configs'].get('cleanup.policy')
            if cleanup_policy and cleanup_policy not in valid_cleanup_policies:
                raise ValueError(f"Invalid cleanup.policy: {cleanup_policy}")

            retention_ms = config['configs'].get('retention.ms')
            if retention_ms is not None:
                try:
                    retention_ms = int(retention_ms)
                    if retention_ms < -1:
                        raise ValueError("retention.ms must be >= -1")
                except ValueError:
                    raise ValueError("retention.ms must be an integer")

def main():
    topics_dir = 'Task4/topics'
    exit_code = 0
    default_bootstrap_servers = '167.99.244.46:29092,167.99.244.46:29093,167.99.244.46:29094'
    
    # Create Kafka admin client
    try:
        admin_client = KafkaAdminClient(
            bootstrap_servers=os.getenv('KAFKA_BOOTSTRAP_SERVERS', default_bootstrap_servers),
            client_id='topic-validator',
            security_protocol='PLAINTEXT'  # Explicitly set security protocol
        )
    except KafkaError as e:
        print(f"Failed to connect to Kafka cluster: {str(e)}", file=sys.stderr)
        sys.exit(1)

    # Validate each topic configuration file
    try:
        for filename in os.listdir(topics_dir):
            if filename.endswith('.yaml'):
                print(f"Processing {filename}")
                file_path = os.path.join(topics_dir, filename)
                try:
                    with open(file_path, 'r') as f:
                        config = yaml.safe_load(f)
                    
                    if not config or 'topics' not in config:
                        raise ValueError("Invalid file format: missing 'topics' key")
                    
                    for topic in config['topics']:
                        validate_topic_config(topic, admin_client)
                        
                        if 'delete' in topic and topic['delete']:
                            print(f"Validated topic deletion: {topic['name']}")
                        else:
                            new_topic = NewTopic(
                                name=topic['name'],
                                num_partitions=topic['partitions'],
                                replication_factor=topic['replication_factor'],
                                topic_configs=topic.get('configs', {})
                            )
                            try:
                                admin_client.create_topics([new_topic], validate_only=True)
                            except KafkaError as e:
                                raise ValueError(f"Invalid topic configuration: {str(e)}")
                            print(f"Validated topic creation: {topic['name']}")
                    print(f"✓ {filename} is valid")
                except Exception as e:
                    print(f"✗ Error in {filename}: {str(e)}", file=sys.stderr)
                    exit_code = 1
    finally:
        admin_client.close()
    
    sys.exit(exit_code)

if __name__ == "__main__":
    main()