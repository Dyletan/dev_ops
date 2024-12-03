# Gitlab runner

### Installing, Registering and cleaning(unregistering, deleting etc...)
---

### Fist of all obtain gitlab runner registration_token
==for this go to==
```
gitlab project > settings > CI/CD > runners > New runner
```
---


### To install gitlab-runner to our machine
`install_gitlab_runner.sh`
```
chmod +x install_gitlab_runner.sh  #to make it executable (is optional)

./install_gitlab_runner
```

### To register runner to gitlab project
`register_gitlab_runner.sh`
```
chmod +x register_gitlab_runner.sh  #to make it executable (is optional)

./register_gitlab_runner <runner_registration_token>   # MUST replace <runner_registration_token> to a real obtained token
```

### To stop, unregister and delete use cleanup
`cleanup.sh`
```
chmod +x cleanup.sh  #to make it executable (is optional)

./cleanup <runner_registration_token>   # MUST replace <runner_registration_token> to a real obtained token
```

# Done!
