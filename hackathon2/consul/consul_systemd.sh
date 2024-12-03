bash -c "cat << EOF >> /etc/systemd/system/consul.service
[Unit]
Description=Consul Service Discovery Agent
Documentation=https://www.consul.io/
After=network.target

[Service]
ExecStart=/usr/bin/consul agent -config-dir=/home/parallels/Desktop/consul/consul.hcl
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
LimitNOFILE=65536
User=root

[Install]
WantedBy=multi-user.target
EOF"

systemctl daemon-reload
systemctl enable consul.service
systemctl start consul.service