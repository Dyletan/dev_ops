FROM python:3.9.20-alpine3.19 AS builder

RUN apk add --no-cache git

WORKDIR /app

RUN git clone https://gitlab.com/lecture-tasks/intro-devops/aiohttp-simple-server.git

RUN pip install --no-cache-dir aiohttp

FROM python:3.9.20-alpine3.19

WORKDIR /app

COPY --from=builder /app /app

EXPOSE 8080

CMD ["python", "main.py"]