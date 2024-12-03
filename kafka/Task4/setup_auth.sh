#!/bin/bash

BROKER_CONTAINERS=("broker01" "broker02" "broker03")

update_kafka_config() {
    local container=$1
    echo "Updating Kafka configuration for $container..."
    
    # Append the ACL configuration to the server.properties file
    docker exec -it $container bash -c "echo 'authorizer.class.name=kafka.security.authorizer.AclAuthorizer' >> /opt/bitnami/kafka/config/server.properties"
    docker exec -it $container bash -c "echo 'super.users=User:ANONYMOUS' >> /opt/bitnami/kafka/config/server.properties"
    docker exec -it $container bash -c "echo 'allow.everyone.if.no.acl.found=true' >> /opt/bitnami/kafka/config/server.properties"
    
    # Verify that the configuration has been added
    docker exec -it $container bash -c "tail -n 10 /opt/bitnami/kafka/config/server.properties"
}

echo "Configuring containers..."

for container in "${BROKER_CONTAINERS[@]}"; do
    update_kafka_config $container
    
    # Restart the container to apply changes
    echo "Restarting $container..."
    docker restart $container
    echo "$container restarted successfully."
done

echo "Configuration completed!"
