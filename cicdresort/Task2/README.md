## Deploy vault
Deploy video: https://www.youtube.com/watch?v=e2uaAoLFPmE

The `deploy.sh` file was used to deploy

## Check
1. Demonstrate that vault is working at http://167.99.244.46:8100
2. The transit vault is working at http://167.99.244.46:8200
3. You can get login tokens using:
```bash
# to get primary vault token
ssh root@167.99.244.46 'cat /root/.vault-token'
# to get transit vault token
ssh root@167.99.244.46 'cat /root/.transit-token'
```
4. Paste the tokens you get using this scritp to login