#!bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 START_PORT-END_PORT"
  exit 1
fi

PORT_RANGE=$1

START_PORT=$(echo $PORT_RANGE | cut -d'-' -f1)
END_PORT=$(echo $PORT_RANGE | cut -d'-' -f2)

servers=()

for PORT in $(seq $START_PORT $END_PORT); do
  tmux new-session -d -s "api_instance_$PORT" "go run main.go -port=$PORT"
  echo "Started API instance on port $PORT"
  servers+=("http://localhost:$PORT")
done


num_servers=${#servers[@]}

counter=0

while true; do
    server=${servers[$counter]}
    echo "Forwarding request to: $server"
    curl -s "$server" -o /dev/null &
    counter=$(( (counter + 1) % num_servers ))
    sleep 1
done