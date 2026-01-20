dockerfile
    # Use an official lightweight Python image.
    FROM python:3.9-slim

    # Set the working directory inside the container.
    WORKDIR /app

    # Copy the requirements file and install dependencies.
    COPY requirements.txt .
    RUN pip install --no-cache-dir -r requirements.txt

    # Copy the rest of the application code.
    COPY . .

    # Tell the container to run the Gunicorn web server on port 8080.
    CMD ["gunicorn", "--bind", "0.0.0.0:8080", "main:app"]