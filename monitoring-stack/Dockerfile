# Base image
FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Copy only requirements first to leverage Docker layer caching
COPY requirements.txt .

# Install runtime dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the metrics-service code
COPY metrics-service/ ./

# Expose the metrics port
EXPOSE 8000

# Non-root user for best practice
RUN useradd -m devuser
USER devuser

# Start the metrics service
CMD ["python", "app.py"]
