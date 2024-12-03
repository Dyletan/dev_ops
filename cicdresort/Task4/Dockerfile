# Start with a minimal base image for Go binaries
FROM golang:1.23 AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy go.mod first to leverage caching
COPY go.mod ./

# Download dependencies
RUN go mod download

# Copy the application source code
COPY main.go .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -o go-api

# Create a minimal runtime image
FROM alpine:latest

# Add CA certificates and timezone data
RUN apk --no-cache add ca-certificates tzdata

# Set the working directory inside the runtime image
WORKDIR /app

# Copy the compiled binary from the builder stage
COPY --from=builder /app/go-api .

# Expose the correct port (8081 as per your main.go)
EXPOSE 8081

# Set the binary as the entry point
ENTRYPOINT ["./go-api"]
