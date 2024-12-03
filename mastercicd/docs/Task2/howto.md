# How-To Guides

## How to Configure Telegram Notifications

1. Create a new Telegram bot via BotFather
2. Get your chat ID using the bot
3. Add to GitLab CI/CD variables:
   - `TELEGRAM_BOT_TOKEN`
   - `TELEGRAM_CHAT_ID`

## How to Manually Check if API is running
1. connect to your server
```bash
    ssh root@$SERVER_IP_ADDRESS
    curl localhost:8081/health
```
2. If it returns '{"status":"ok","message":"Сервис запущен и работает"}' API is running, otherwise no

## How to Update the API Port

1. Modify the `PORT` environment variable in `go-api.service`:
```ini
Environment=PORT=your-new-port
```
2. Update the health check in `.gitlab-ci.yml` to use the new port.
3. Redeploy the application.

## How to Trigger the GitLab CI pipeline

1. Stage and commit any change in Task2 folder to master or release-* branches
2. Push the commit
3. In GitLab repository in Build->Pipelines see if the pipeline build started


