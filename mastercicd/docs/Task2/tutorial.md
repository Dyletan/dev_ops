# Getting Started with Go API Deployment

This tutorial will guide you through deploying your first Go API using our GitLab CI/CD pipeline.

## Prerequisites

- GitLab account
- Configuring GitLab CI/CD variables like:
- Access to a deployment server that has go 1.23 installed
- Telegram bot for notifications
- SSH key pair for deployment

## Step-by-Step Deployment

1. Clone the repository:
```bash
git clone https://gitlab.com/devopsforcheck/mastercicd.git
cd mastercicd
```

2. Configure your deployment variables in GitLab:
   - `SSH_PRIVATE_KEY`: Your deployment SSH private key
   - `SSH_KNOWN_HOSTS`: Server SSH fingerprint
   - `TELEGRAM_BOT_TOKEN`: Your Telegram bot token
   - `TELEGRAM_CHAT_ID`: Your Telegram chat ID
   - `APP_URL`: Your application URL with the running port

3. Push your changes to the master branch:
```bash
git add remote origin https://gitlab.com/yourgroup/yourrepository.git
git add .
git commit -m "first commit"
git push origin master
```

4. Navigate to GitLab CI/CD pipelines and manually trigger the deployment.

5. Verify the deployment by checking you telegram bot or manually testing by:
```bash
curl http://your-server:8081/health
```