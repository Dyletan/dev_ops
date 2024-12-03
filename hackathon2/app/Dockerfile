# Use a minimal Python image
FROM python:3.11-slim

# Set a working directory
WORKDIR /app

# Copy dependencies first to leverage caching
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY .. .

# Set a non-root user
RUN useradd -m appuser
USER appuser

# Expose port for the service
EXPOSE 8000

# Default command to run the service
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
