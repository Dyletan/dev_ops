## Overview

A script that creates a user executor that has the rights to execute the go binary to launch the API from task 4.
Also it creates a systemd file that uses executor in systemd service to launch the binary

## Prerequisites

1. Have the `linux` folder in your `/home` directory
2. To test logs, launch setup_logrotate.sh from Task4 according to instructions
3. Have sudo priveleges

## Laucnh

In terminal execute:

```bash
cd home/linux/Task5
sudo chmod +x create_executor.sh create_service.sh
sudo ./create_executor.sh
sudo ./create_service.sh
```

## Check

```bash
sudo systemctl status go_api.service
```
