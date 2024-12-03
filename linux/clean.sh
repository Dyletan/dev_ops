#!/bin/bash

NOMAD_FILE="/home/linux/Task8/example.nomad"
DEFAULT_JOB_NAME="example"
if [ ! -f "$NOMAD_FILE" ]; then
    echo "Error: File $NOMAD_FILE does not exist."
    exit 1
fi

sed -i "s/job \"[^\"]*\"/job \"$DEFAULT_JOB_NAME\"/" "$NOMAD_FILE"

if [ $? -eq 0 ]; then
    echo "Job name has been reset to '$DEFAULT_JOB_NAME'."

else
    echo "Failed to reset the job name. Please check the file and try again."
    exit 1
fi

if [ -f "$NOMAD_FILE.bak" ]; then
    rm -f "$NOMAD_FILE.bak"
    echo "Backup file $NOMAD_FILE.bak removed."
fi


if [ -f "$HOME/.ssh/id_rsa" ]; then
    rm -f "$HOME/.ssh/id_rsa" "$HOME/.ssh/id_rsa.pub"
    echo "SSH keys removed."
fi

if [ -f "$HOME/.ssh/known_hosts" ]; then
    sed -i '/167.99.244.46/d' "$HOME/.ssh/known_hosts"
    echo "Removed 167.99.244.46 from known_hosts."
fi


LOG_DIR="/home/logs"
if [ -d "$LOG_DIR" ]; then
    rm -rf "$LOG_DIR"
    echo "Logs directory removed."
fi

LOGROTATE_CONF="/etc/logrotate.d/task4_logs"
if [ -f "$LOGROTATE_CONF" ]; then
    rm -f "$LOGROTATE_CONF"
    echo "Logrotate configuration removed."
fi

systemctl stop logrotate.timer 2>/dev/null
systemctl disable logrotate.timer 2>/dev/null
rm -f /etc/systemd/system/logrotate.service /etc/systemd/system/logrotate.timer
systemctl daemon-reload

echo "Logrotate timer and service removed."


if id "executor" &>/dev/null; then
    userdel -r executor 2>/dev/null
    echo "User 'executor' removed."
fi

GO_API_SERVICE="/etc/systemd/system/go_api.service"
if [ -f "$GO_API_SERVICE" ]; then
    systemctl stop go_api.service 2>/dev/null
    systemctl disable go_api.service 2>/dev/null
    rm -f "$GO_API_SERVICE"
    systemctl daemon-reload
    echo "Go API service removed."
fi


iptables -t nat -D PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080 2>/dev/null
iptables -t nat -D OUTPUT -p tcp -d localhost --dport 80 -j REDIRECT --to-port 8080 2>/dev/null
if command -v netfilter-persistent &> /dev/null; then
    netfilter-persistent save
    netfilter-persistent reload
fi
echo "Iptables rules cleared."

echo "Cleanup completed."
