#!/bin/bash
docker stop running_devopsina
docker rm running_devopsina

cd terraform
terraform init 
terraform apply --auto-approve

FLYWAY_IMAGE="flyway/flyway:11.0"
FLYWAY_CONF_DIR="$(pwd)/flyway/conf"
FLYWAY_SQL_DIR="$(pwd)/flyway/sql"
FLYWAY_CONF_FILE="$FLYWAY_CONF_DIR/flyway.conf"

# Function to get secrets from Vault
get_secret_from_vault() {
  local field=$1
  local vault_addr="http://137.184.180.202:8200"
  local vault_token="root"

  export VAULT_ADDR=$vault_addr
  export VAULT_TOKEN=$vault_token

  vault kv get -field=$field secret/hackakaton
}

# Fetch secrets dynamically
url=$(get_secret_from_vault "url")
user=$(get_secret_from_vault "user")
password=$(get_secret_from_vault "password")

# Create Flyway configuration directory if it doesn't exist
mkdir -p "$FLYWAY_CONF_DIR"
mkdir -p "$FLYWAY_SQL_DIR"

# Dynamically create the flyway.conf file
cat <<EOF > "$FLYWAY_CONF_FILE"
flyway.url=$url
flyway.user=$user
flyway.password=$password
EOF

echo "Flyway configuration file created at $FLYWAY_CONF_FILE"

# Run Flyway migrations
echo "Running Flyway migrations..."
docker run --rm \
  -v "$FLYWAY_CONF_DIR:/flyway/conf" \
  -v "$FLYWAY_SQL_DIR:/flyway/sql" \
  $FLYWAY_IMAGE -configFiles=/flyway/conf/flyway.conf migrate


# FLYWAY_IMAGE="flyway/flyway:11.0"

# # Run Flyway migrations
# echo "Running Flyway migrations..."
# docker run --rm \
#   -v $(pwd)/flyway/conf:/flyway/conf \
#   -v $(pwd)/flyway/sql:/flyway/sql \
#   $FLYWAY_IMAGE -configFiles=conf/flyway.conf migrate