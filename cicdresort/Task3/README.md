## Config
To configure vault for integration with Gitlab CI/CD firstly run ```config.sh``` with ```sh config.sh``` command.

It creates necessary policies, enables secret engines and writes secret for certain users.


## How to check
Inside of Task3 directory click on the green check button and rerun the pipelines. After both of them finish successfuly you can enter them and see the result. Result will be secret from the Vault displayed in the job logs.

![Image](https://gitlab.com/devopsforcheck/cicdresort/-/main/Task3/CheckButton.png?raw=true)