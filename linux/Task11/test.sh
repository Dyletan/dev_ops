for PORT in {8000..8005}; do
  response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$PORT/)
  if [ "$response" -eq 200 ]; then
    echo "Server on port $PORT is responding with HTTP 200."
  else
    echo "Server on port $PORT is not responding correctly (HTTP $response)."
  fi
done