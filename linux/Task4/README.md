## Prerequisites

1. Have sudo priveleges

## Launch

In terminal run:

```bash
cd home/linux/Task4
go build -o main main.go
sudo chmod +x main setup_logrotate.sh
sudo ./setup_logrotate.sh 
```

## Check

Setup logrotate doesn't provide functionality to start the API, we recommend to lauch it using the systemd service file, which we provide in Task5. You can also do it manually if you must. After you laucnh it, you can check it with:

``` bash
# Trigger API endpoint
curl http://localhost:8080/

# Watch the application logs
tail -f /home/logs/app.log

# Verify Logrotate Timer Status
sudo systemctl status logrotate.timer
sudo systemctl list-timers | grep logrotate
sudo logrotate -d /etc/logrotate.d/task4_logs

# Generate logs to trigger rotation
for i in {1..40000}; do
    curl http://localhost:8080/
done

ls -lh /home/logs/
cat /home/log_rotates.log
```

If `sudo logrotate -d /etc/logrotate.d/task4_logs` gives an error 'error: skipping "/home/logs/app.log" because parent directory has insecure permissions' you should run `chown -R root:root home/logs` and rerun `sudo logrotate -d /etc/logrotate.d/task4_logs`