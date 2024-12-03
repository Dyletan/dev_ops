**Make the Script Executable**
    
```bash
    chmod +x iptables_test.sh reset_iptables.sh
    
```
    
**Run the Script**:
    
```bash
./iptables_test.sh
    
```


**Flush all rules**
```bash
./reset_iptables.sh
    
```

**How to test**
1. Run this to start api: ```go run main.go```
2. ```chmod +x iptables_test.sh reset_iptables.sh```
3. Run this command to set firewall: ```./iptables_test.sh```
4. Then you need to find the ip of Virtual Machine.
5. Run this commands on VM to find ip: ```ip a``` or ```ifconfig```. (ip should be like this 192.168......).
6. Then outside of the VM open terminal and run this command ```curl http://<ip of VM>:8080``` DON'T RUN THIS COMMAND ON VM.
7. To reset firewall, run this: ```./reset_iptables.sh```