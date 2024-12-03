#!/bin/bash

ARCHITECTURE=$(uname -m)

if [ "$ARCHITECTURE" = "x86_64" ]; then
    GITLAB_ARCHITECTURE="amd64"
elif [ "$ARCHITECTURE" = "aarch64" ]; then
    GITLAB_ARCHITECTURE="arm64"
else
    echo "Unsupported architecture: $ARCHITECTURE"
    exit 1
fi

if ! command -v gitlab-runner &> /dev/null; then
    sudo curl -L --output /usr/local/bin/gitlab-runner "https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/latest/binaries/gitlab-runner-linux-$GITLAB_ARCHITECTURE"
    sudo chmod +x /usr/local/bin/gitlab-runner

    sudo useradd --comment 'Gitlab Runner' --create-home gitlab-runner --shell /bin/bash || true
    sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
    sudo systemctl enable gitlab-runner
    sudo systemctl start gitlab-runner

    echo "Gitlab Runner installed and configured to start on boot"
else
    echo "Gitlab Runner is already installed"
fi