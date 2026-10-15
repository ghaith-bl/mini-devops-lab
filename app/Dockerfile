# Base image with Python (slim version)
FROM docker.io/library/python:3.12-slim

# Working directory inside the container
WORKDIR /app

# Copy and install dependencies first (layer caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Then copy the application code
COPY app.py .

# Run as a non-root user
USER 1000

EXPOSE 5000
CMD ["python", "app.py"]
