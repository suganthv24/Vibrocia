#!/bin/bash

# run_vibrocia_vscode_mongo.sh
# This script runs the Vibrocia web application in VS Code with MongoDB as the database.
# It executes the Django backend (all apps) and FastAPI AI service setup scripts.
# Prerequisites: VS Code, Docker, Docker Compose, Python 3.9+, MongoDB (for manual setup).
# Run this script from the project root directory (vibrocia/) in VS Code's integrated terminal.
# Before running:
# 1. Open the project: File > Open Folder > select vibrocia/
# 2. Install extensions:
#    - Docker (Microsoft)
#    - Python (Microsoft)
#    - Shell Script (Timon Wong)
#    - MongoDB for VS Code (MongoDB)
# 3. Ensure scripts are executable: chmod +x setup_django_backend.sh setup_fastapi_ai_service.sh run_vibrocia_vscode_mongo.sh
# 4. Place all provided files in their respective directories.
# 5. Open the integrated terminal: Terminal > New Terminal (or Ctrl+`)
# 6. Run: ./run_vibrocia_vscode_mongo.sh

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting Vibrocia setup in VS Code with MongoDB...${NC}"

# Check if running in VS Code
if [ -z "$VSCODE_PID" ]; then
    echo -e "${RED}This script is intended for VS Code. Please run it in VS Code's integrated terminal.${NC}"
    echo "Open VS Code, navigate to the vibrocia/ folder, and run: ./run_vibrocia_vscode_mongo.sh"
    exit 1
fi

# Check if setup scripts exist
if [ ! -f "setup_django_backend.sh" ] || [ ! -f "setup_fastapi_ai_service.sh" ]; then
    echo -e "${RED}Setup scripts (setup_django_backend.sh, setup_fastapi_ai_service.sh) are missing.${NC}"
    echo "Ensure both scripts are in the vibrocia/ directory."
    exit 1
fi

# Check if project structure is correct
if [ ! -f "docker-compose.yml" ] || [ ! -d "backend" ] || [ ! -d "ai_service" ]; then
    echo -e "${RED}Project structure is incomplete. Ensure all files and directories are present.${NC}"
    exit 1
fi

# Prompt for setup method
echo "Choose setup method for Vibrocia:"
echo "1. Docker (recommended)"
echo "2. Manual (requires MongoDB and Python)"
read -p "Enter choice (1 or 2): " SETUP_METHOD

# Validate setup method
if [ "$SETUP_METHOD" != "1" ] && [ "$SETUP_METHOD" != "2" ]; then
    echo -e "${RED}Invalid choice. Please run the script again and select 1 or 2.${NC}"
    exit 1
fi

# Run Django backend setup
echo -e "${GREEN}Running Django backend setup with MongoDB...${NC}"
chmod +x setup_django_backend.sh
./setup_django_backend.sh <<EOF
$SETUP_METHOD
EOF

# Wait for Django setup to complete
echo "Waiting for Django backend to be ready..."
sleep 5

# Run FastAPI AI service setup
echo -e "${GREEN}Running FastAPI AI service setup...${NC}"
chmod +x setup_fastapi_ai_service.sh
./setup_fastapi_ai_service.sh <<EOF
$SETUP_METHOD
EOF

echo -e "${GREEN}Vibrocia setup complete in VS Code with MongoDB!${NC}"
echo "Access the application at http://localhost:8000"
echo "Access the AI service at http://localhost:8001"
echo "To access the admin panel, go to http://localhost:8000/admin/ (use superuser credentials if created)."
if [ "$SETUP_METHOD" = "1" ]; then
    echo "To stop the application, run in the terminal: docker-compose down"
else
    echo "To stop the application, kill the Django and FastAPI processes (PIDs displayed in setup scripts)."
    echo "Use: ps aux | grep python (for Django) and ps aux | grep uvicorn (for FastAPI), then kill <PID>"
fi
echo "To debug in VS Code, set breakpoints in backend/ or ai_service/ files and use the Python debugger (Run > Start Debugging)."
echo "To view MongoDB data, use the MongoDB for VS Code extension or run: mongosh vibrocia_db --username mongo_user --password mongo_password"