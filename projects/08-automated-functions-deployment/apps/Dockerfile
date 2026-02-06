# /apps/Dockerfile
FROM python:3.11-slim

# Set the working directory in the container
WORKDIR /app

# Copy the dependencies file and install them
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Set the command to run the Functions Framework
# This tells GCP to run the "hello_etl" function from the "main.py" file
CMD exec functions-framework --target=hello_etl --port=$PORT