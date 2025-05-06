#!/bin/bash

# setup_fastapi_ai_service.sh
# This script sets up and runs the FastAPI AI service for the Vibrocia web application.
# Prerequisites: Docker, Docker Compose, Python 3.9+ (for manual setup).
# Run this script from the project root directory (vibrocia/).

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting FastAPI AI service setup for Vibrocia...${NC}"

# Check if ai_service directory exists
if [ ! -d "ai_service" ] || [ ! -f "ai_service/main.py" ]; then
    echo -e "${RED}ai_service directory or main.py is missing. Ensure the project structure is correct.${NC}"
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed. Please install Docker and Docker Compose or use manual setup.${NC}"
    exit 1
fi

# Option to choose setup method
echo "Choose setup method for FastAPI AI service:"
echo "1. Docker (recommended)"
echo "2. Manual (requires Python)"
read -p "Enter choice (1 or 2): " SETUP_METHOD

if [ "$SETUP_METHOD" = "1" ]; then
    # Docker Setup
    echo -e "${GREEN}Setting up FastAPI AI service with Docker...${NC}"

    # Check if docker-compose.yml exists
    if [ ! -f "docker-compose.yml" ]; then
        echo -e "${RED}docker-compose.yml is missing. Please ensure it is present as provided.${NC}"
        exit 1
    fi

    # Check if Dockerfile exists
    if [ ! -f "ai_service/Dockerfile" ]; then
        echo -e "${RED}Dockerfile is missing. Creating it...${NC}"
        cat <<EOT > ai_service/Dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
EOT
    fi

    # Build and start Docker service (ai-service)
    echo "Building and starting Docker service..."
    docker-compose up --build -d ai-service

    # Wait for service to be ready
    echo "Waiting for service to start..."
    sleep 5

    echo -e "${GREEN}FastAPI AI service setup complete! Access at http://localhost:8001${NC}"
    echo "To stop the AI service, run: docker-compose down"

elif [ "$SETUP_METHOD" = "2" ]; then
    # Manual Setup
    echo -e "${GREEN}Setting up FastAPI AI service manually...${NC}"

    # Check if Python is installed
    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}Python 3 is not installed. Please install Python 3.9 or higher.${NC}"
        exit 1
    fi

    # Install AI service dependencies
    echo "Installing AI service dependencies..."
    cd ai_service
    python3 -m venv venv
    source venv/bin/activate
    pip install --upgrade pip
    pip install -r requirements.txt

    # Start FastAPI server
    echo "Starting FastAPI AI service..."
    uvicorn main:app --host 0.0.0.0 --port 8001 &
    FASTAPI_PID=$!

    echo -e "${GREEN}FastAPI AI service setup complete! Access at http://localhost:8001${NC}"
    echo "To stop the AI service, run: kill $FASTAPI_PID"
    echo "FastAPI PID: $FASTAPI_PID"

else
    echo -e "${RED}Invalid choice. Please run the script again and select 1 or 2.${NC}"
    exit 1
fi

echo -e "${GREEN}FastAPI AI service is ready! Access at http://localhost:8001${NC}"
echo "Note: The Django backend must be running for full functionality. Run setup_django_backend.sh separately."