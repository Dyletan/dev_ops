# Use the official Golang image as the base
FROM golang:1.23.0-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy go.mod and go.sum files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy the source code into the container
COPY . .

# Build the Go app
RUN CGO_ENABLED=0 GOOS=linux go build -o api .

# Expose the port that the API will run on
EXPOSE 8080

# Command to run the executable
CMD ["./api"]
