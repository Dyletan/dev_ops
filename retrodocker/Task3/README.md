## Gitlab CI Runner in Docker container

### docker-compose.yml content explanation
1. docker-compose.yml:3 - pulls official gitlab runner image
2. docker-compose.yml:6 - mounts docker socket so that runner could execute commands. (Using the docker image to run jobs means that pretty much the only thing a build step can run is a docker command. - StackOverflow)

## How to run
cd into Task2 repository and run ```docker compose up --build```

In the gitlab CI/CD settings open "Runners" tab, create project runner, put check on "run untagged jobs" and create runner. There will be command given to run in the docker container exec, input and before launching add ```--docker-network-mode 'host'```. Expample: ```gitlab-runner register  --url https://gitlab.com  --token glrt-t3_74q-8wDHyg1cWBSv6Ace --docker-network-mode 'host'```. <br><br>
 When asked for gitlab instance and runner name leave everything as it is, then for the executor write ```docker``` and default docker image enter ```python:alpine```. (Because test .gitlab-ci file run python script just for checking). 

## What to present
Enter repository settings and open "Runners" tab, in project runners there will be our runner. Then you can enter jobs tab in "Build", enter last successful job and on the right side there will be our runner shown.