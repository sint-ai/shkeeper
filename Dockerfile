FROM python:3.9-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    sqlite3 \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements first to leverage Docker cache
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY . .

# Create necessary directories and set permissions
RUN mkdir -p /app/data && \
    chmod -R 755 /app/data

# Expose the port
EXPOSE 5000

# Set environment variables for Railway
ENV PORT=5000 \
    HOST=0.0.0.0

# Start the application
CMD gunicorn \
    --access-logfile - \
    --workers 2 \
    --threads 32 \
    --worker-class gthread \
    --timeout 30 \
    --bind ${HOST}:${PORT} \
    "shkeeper:create_app()"
