#!/bin/bash

LOG_DIR="/home/logs"
APP_LOG="$LOG_DIR/app.log"
ROTATIONS_LOG="/home/log_rotates.log"

if [ ! -d "$LOG_DIR" ]; then
    mkdir -p "$LOG_DIR"
    setfacl -m o:r $DIR
    setfacl -d -m o:r $DIR
    ../Task7/logs_permissions.sh
fi

bash -c "cat << EOF > /etc/systemd/system/logrotate.service
[Unit]
Description=Rotate log files

[Service]
Type=oneshot
ExecStart=/usr/sbin/logrotate /etc/logrotate.conf
EOF"

bash -c "cat << EOF > /etc/systemd/system/logrotate.timer
[Unit]
Description=Run logrotate every minute
[Timer]
OnCalendar=*-*-* *:*:00
Persistent=true

[Install]
WantedBy=timers.target
EOF"

systemctl daemon-reload
systemctl enable logrotate.timer
systemctl start logrotate.timer

bash -c "cat << EOF > /etc/logrotate.d/task4_logs
$APP_LOG {
    size 1M
    rotate 3
    create 644 root root
    copytruncate
    postrotate
        echo \"log rotated at \$(date)\" >> $ROTATIONS_LOG
    endscript
}
EOF"

touch "$APP_LOG" "$ROTATIONS_LOG"
chmod 644 "$APP_LOG" "$ROTATIONS_LOG"