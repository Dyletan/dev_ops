#!/bin/bash

sudo systemctl stop gitlab-runner

sudo gitlab-runner unregister --all-runners
strings=$1
tokenString="${strings:8:8}"
sudo gitlab-runner unregister --token "$tokenString"

sudo rm /usr/local/bin/gitlab-runner
sudo userdel -r gitlab-runner
sudo systemctl disable gitlab-runner
sudo rm /etc/systemd/system/gitlab-runner.service

echo "Gitlab Runner stopped, unregistered, and removed from the system"