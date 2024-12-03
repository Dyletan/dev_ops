#!/bin/bash

# Flush any existing rules 
sudo iptables -F

# Allow traffic from localhost (127.0.0.1) to API service on port 8080
#sudo iptables -A INPUT -p tcp -s 127.0.0.1 --dport 8080 -j ACCEPT

# Allow traffic from a specific IP
sudo iptables -A INPUT -p tcp -s <put here ip of VM> --dport 8080 -j ACCEPT

# Block all other traffic to the API service on port 8080
sudo iptables -A INPUT -p tcp --dport 8080 -j DROP

# Allow established connections
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

echo "iptables rules set for testing"
