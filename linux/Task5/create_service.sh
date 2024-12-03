if [ -f "/etc/systemd/system/go_api.service" ]; then
    echo "Systemd unit file already exists."
    exit 0
else
    tee "/etc/systemd/system/go_api.service" << EOF
[Unit]
Description=A simple Go API
After=network.target

[Service]
ExecStart=/home/linux/Task4/main
WorkingDirectory=/home/linux/Task4
StandardOutput=append:/home/logs/app.log
StandardError=append:/home/logs/app.log
Restart=always
User=executor

[Install]
WantedBy=multi-user.target
EOF
echo "Systemd unit file created successfuly."
fi

systemctl daemon-reload
systemctl enable go_api.service
systemctl start go_api.service
echo "Service started"