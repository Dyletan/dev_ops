**Make the Script Executable**
    
```bash
chmod +x load_balancer.sh
```
    
**Run the Script**:
Provide the port range as an argument.

```bash
./load_balancer.sh 8000-8005
```

**Check**

In separate window, while load_balancer.sh is running run:
```bash
cd /home/linux/Task11
chmod +x test.sh
./test.sh
```

If it returns HTTP 200 response, everything is working fine