# Use a lightweight Python base image
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Copy the training script into the container
COPY main.py .

# When the container starts, run the training script
ENTRYPOINT ["python", "main.py"]