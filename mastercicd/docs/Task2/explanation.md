# Architecture and Concepts

## Overview

This project implements a simple Go REST API with automated deployment using GitLab CI/CD. The architecture implements continuous integration, automated deployment, and health monitoring through a telegram bot.

## Key Components

### 1. Go API Service
The core application is a minimal REST API written in Go, providing basic health checking capabilities.

### 2. Deployment Pipeline
The deployment process uses a two-stage pipeline:
- **Build**: Compiles the Go application with cross-compilation settings
- **Deploy**: Uses SSH for secure deployment to the target server

### 3. Service Management
The application runs as a systemd service, ensuring an automatic restart on failure

### 4. Monitoring
The deployment includes:
- Health endpoint for status checking
- Telegram notifications for deployment status
- Systemd service monitoring

## Design Decisions

1. **Manual Deployment Trigger**: The deploy stage requires manual intervention for additional deployment control.
2. **Health Checking**: Implements retry logic with detailed failure reporting.
