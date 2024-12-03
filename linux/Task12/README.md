## Prerequisites

You must run `git clone` in yout terminal in `/home` directory (otherwise some tasks might have troubles launching)
```bash
git clone https://gitlab.com/devopsforcheck/linux.git
```

## How to launch 

```bash
cd /home/linux/Task12
make task1 # launches task1
make task2 # launches task2
...
```

## Tips

- When checking any task, refer to its README, every step to check is there
- When launching task2 it will take a while to execute, so start checking other tasks in a separate terminal window
- When launching task3 you will be taken inside the server for checking if it works, type `exit` to exit it
- You should run task5 before checking task4 to run the api
- When running test in task4 that curl the localhost:8080 40000 times, you should start checking other tasks in other windows