**Make the Script Executable**
    
```bash
chmod +x script.sh 
```
    
**Run the Script**:
Provide the new job name.
    
```bash
./script.sh test404
```

**Check**
To see the changes you can run:
```bash
cat /home/linux/nomad.example
```

The job name should now be `test404`