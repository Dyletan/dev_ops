# Technical Reference

## Project Structure

```
.
├── .gitlab-ci.yml    # CI/CD pipeline configuration
├── go-api.service    # Systemd service configuration
├── main.go           # API implementation
└── go.mod            # Go module definition
```

## CI/CD Pipeline Stages

### Build Stage
- Triggers on: master branch and release-* branches
- Uses: golang:1.23 image
- Outputs: go-api binary artifact

### Deploy Stage
- Manual trigger required
- Environment: production
- Prerequisites: SSH access, Telegram credentials
- Health check: Attempts 5 times over 25 seconds

## API Endpoints

### GET /health
Returns service health status

**Response:**
```json
{
    "status": "ok",
    "message": "Сервис запущен и работает"
}
```

## Environment Variables

- `PORT`: API listening port (default: 8081)
- `DEPLOY_SERVER`: Target deployment server
- `SSH_PRIVATE_KEY`: Deployment SSH key
- `SSH_KNOWN_HOSTS`: Server SSH fingerprint
- `TELEGRAM_BOT_TOKEN`: Notification bot token
- `TELEGRAM_CHAT_ID`: Notification channel ID