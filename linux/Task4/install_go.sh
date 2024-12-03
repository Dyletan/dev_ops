#!/bin/bash

ARCHITECTURE=$(uname -m)
if [ "$ARCHITECTURE" = "x86_64" ]; then
    ARCHITECTURE="amd64"
elif [[ "$ARCHITECTURE" == "aarch64" ]]; then
    ARCHITECTURE="arm64"
else
    echo "Unsupported architecture: $ARCHITECTURE"
    exit 1
fi

GO_VERSION="1.23.0"
GO="go${GO_VERSION}.linux-${ARCHITECTURE}.tar.gz"

echo "Downloading Go $GO_VERSION for $ARCHITECTURE..."
wget "https://storage.googleapis.com/golang/${GO}" -O "/tmp/${GO}"

echo "Extracting Go..."
sudo tar -C /usr/local -xzf "/tmp/${GO}"
rm "/tmp/${GO}"

mkdir -p /opt/go/.go

echo "Setting up Go environment variables..."

export PATH=$PATH:/usr/local/go/bin
export GOPATH=/opt/go/.go
export PATH=$PATH:$GOPATH/bin

echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.bashrc
echo "export GOPATH=/opt/go/.go" >> ~/.bashrc
echo "export PATH=\$PATH:\$GOPATH/bin" >> ~/.bashrc