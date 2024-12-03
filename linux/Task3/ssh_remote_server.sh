#!/bin/bash

check_ssh_keygen_installed() {
  if ! command -v ssh-keygen &> /dev/null; then
    echo "ssh-keygen not found. Installing openssh-client..."
    apt-get update && apt-get install -y openssh-client
  fi
}

check_ssh_key() {
  if [ -f "$HOME/.ssh/id_rsa" ]; then
    echo "SSH key already exists."
  else
    generate_ssh_key
  fi
}

generate_ssh_key() {
  echo "SSH key not found. Generating new SSH key pair..."
  ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -N ""
  echo "SSH key generated successfully."
}

copy_ssh_key_to_remote() {
  read -sp "Enter the password for root@167.99.244.46: " REMOTE_PASS
  echo ""

  if ! command -v sshpass &> /dev/null; then
    echo "Installing sshpass..."
    apt-get install -y sshpass
  fi

  echo "Adding the remote server to known_hosts..."
  ssh-keyscan -H 167.99.244.46 >> "$HOME/.ssh/known_hosts"

  echo "Copying the public SSH key to the remote server..."
  sshpass -p "$REMOTE_PASS" ssh-copy-id -i "$HOME/.ssh/id_rsa.pub" root@167.99.244.46

  if [ $? -eq 0 ]; then
    echo "Public key copied successfully. You can now log in without a password."
  else
    echo "Failed to copy the SSH key. Please check your connection and try again."
  fi
}

echo "Checking if ssh-keygen is installed..."
check_ssh_keygen_installed

echo "Checking for existing SSH key..."
check_ssh_key

copy_ssh_key_to_remote
