#!/bin/bash

REGISTRATION_TOKEN=$1

if [ -z "$REGISTRATION_TOKEN" ]; then
    echo "Usage: ./register_gitlab_runner.sh <REGISTRATION_TOKEN>"
    exit 1
fi

if sudo gitlab-runner list | grep -q "shell"; then
    echo "GitLab Runner is already registered."
else
    sudo gitlab-runner register \
        --non-interactive \
        --url "https://gitlab.com/" \
        --token "$REGISTRATION_TOKEN" \
        --executor "shell" \
        --description "Linux GitLab Runner"
        
    echo "GitLab Runner registered"
fi
