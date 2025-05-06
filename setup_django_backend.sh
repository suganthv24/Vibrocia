#!/bin/bash

# setup_django_backend.sh
# This script sets up and runs the Django backend for Vibrocia with MongoDB.
# Includes apps: accounts, survey, dashboard, roleplay, chatbot, challenges, learning, gamification.
# Prerequisites: Docker, Docker Compose, Python 3.9+ (for manual setup).
# Run this script from the project root directory (vibrocia/).

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting Django backend setup for Vibrocia with MongoDB...${NC}"

# Check if backend directory exists
if [ ! -d "backend" ] || [ ! -f "backend/manage.py" ]; then
    echo -e "${RED}Backend directory or manage.py is missing. Ensure the project structure is correct.${NC}"
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed. Please install Docker and Docker Compose or use manual setup.${NC}"
    exit 1
fi

# Option to choose setup method
echo "Choose setup method for Django backend:"
echo "1. Docker (recommended)"
echo "2. Manual (requires MongoDB and Python)"
read -p "Enter choice (1 or 2): " SETUP_METHOD

if [ "$SETUP_METHOD" = "1" ]; then
    # Docker Setup
    echo -e "${GREEN}Setting up Django backend with Docker and MongoDB...${NC}"

    # Check if docker-compose.yml exists
    if [ ! -f "docker-compose.yml" ]; then
        echo -e "${RED}docker-compose.yml is missing. Please ensure it is present as provided.${NC}"
        exit 1
    fi

    # Check if Dockerfile exists
    if [ ! -f "backend/Dockerfile" ]; then
        echo -e "${RED}Dockerfile is missing. Please ensure it is present as provided.${NC}"
        exit 1
    fi

    # Build and start Docker services (web and mongo)
    echo "Building and starting Docker services..."
    docker-compose up --build -d web mongo

    # Wait for services to be ready
    echo "Waiting for services to start..."
    sleep 10

    # Create migrations for survey app
    echo "Creating migrations for survey app..."
    docker-compose exec web python manage.py makemigrations survey

    # Apply Django migrations
    echo "Applying Django migrations..."
    docker-compose exec web python manage.py migrate

    # Migrate existing survey data (e.g., goals to questions)
    echo "Migrating existing survey data..."
    docker-compose exec web python manage.py shell <<EOF
from survey.models import Survey
for survey in Survey.objects.all():
    if hasattr(survey, 'goals') and survey.goals and not survey.questions:
        survey.questions = survey.goals
        survey.save()
    if not survey.title:
        survey.title = "Untitled Survey"
        survey.save()
exit()
EOF

    # Create superuser (optional, uncomment to enable)
    # echo "Creating superuser..."
    # docker-compose exec web python manage.py createsuperuser

    # Create initial data (challenges, training modules, and sample survey)
    echo "Creating initial data..."
    docker-compose exec web python manage.py shell <<EOF
from challenges.models import DailyChallenge
from learning.models import TrainingModule
from survey.models import Survey
from accounts.models import User
DailyChallenge.objects.get_or_create(title="Practice Pitch", defaults={"description": "Practice a 1-min pitch.", "xp_reward": 10})
TrainingModule.objects.get_or_create(title="Public Speaking Basics", defaults={"content": "Learn to speak confidently.", "category": "Speaking"})
user, _ = User.objects.get_or_create(username="admin", defaults={"email": "admin@example.com"})
user.set_password("admin123")
user.save()
survey, _ = Survey.objects.get_or_create(title="Feedback Survey", user=user, defaults={"questions": '[{"text": "How was your experience?"}]'})
survey.set_questions([{"text": "How was your experience?"}, {"text": "What can we improve?"}])
survey.save()
exit()
EOF

    echo -e "${GREEN}Django backend setup complete! Access at http://localhost:8000${NC}"
    echo "To stop the backend, run: docker-compose down"

elif [ "$SETUP_METHOD" = "2" ]; then
    # Manual Setup
    echo -e "${GREEN}Setting up Django backend manually with MongoDB...${NC}"

    # Check if Python is installed
    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}Python 3 is not installed. Please install Python 3.9 or higher.${NC}"
        exit 1
    fi

    # Check if MongoDB is installed
    if ! command -v mongod &> /dev/null; then
        echo -e "${RED}MongoDB is not installed. Please install MongoDB (e.g., choco install mongodb on Windows).${NC}"
        exit 1
    fi

    # Start MongoDB service
    echo "Starting MongoDB service..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew services start mongodb-community || echo "MongoDB already running or error occurred."
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        net start MongoDB || echo "MongoDB already running or error occurred."
    else
        sudo systemctl start mongod || echo "MongoDB already running or error occurred."
    fi

    # Create MongoDB user and database
    echo "Configuring MongoDB user and database..."
    mongosh admin <<EOF
db.createUser({
    user: "mongo_user",
    pwd: "mongo_password",
    roles: [{ role: "readWrite", db: "vibrocia_db" }]
})
exit
EOF

    # Install backend dependencies
    echo "Installing backend dependencies..."
    cd backend
    python3 -m venv venv
    source venv/bin/activate
    pip install --upgrade pip
    pip install -r requirements.txt

    # Verify custom_filters.py exists
    if [ ! -f "custom_filters.py" ]; then
        echo -e "${RED}custom_filters.py is missing. Creating it...${NC}"
        cat <<EOT > custom_filters.py
from django import template

register = template.Library()

@register.filter
def select_module(logs, module):
    for log in logs:
        if log.module.id == module.id and log.completed:
            return True
    return False
EOT
    fi

    # Create migrations for survey app
    echo "Creating migrations for survey app..."
    python manage.py makemigrations survey

    # Apply Django migrations
    echo "Applying Django migrations..."
    python manage.py migrate

    # Migrate existing survey data (e.g., goals to questions)
    echo "Migrating existing survey data..."
    python manage.py shell <<EOF
from survey.models import Survey
for survey in Survey.objects.all():
    if hasattr(survey, 'goals') and survey.goals and not survey.questions:
        survey.questions = survey.goals
        survey.save()
    if not survey.title:
        survey.title = "Untitled Survey"
        survey.save()
exit()
EOF

    # Create superuser (optional, uncomment to enable)
    # echo "Creating superuser..."
    # python manage.py createsuperuser

    # Create initial data
    echo "Creating initial data..."
    python manage.py shell <<EOF
from challenges.models import DailyChallenge
from learning.models import TrainingModule
from survey.models import Survey
from accounts.models import User
DailyChallenge.objects.get_or_create(title="Practice Pitch", defaults={"description": "Practice a 1-min pitch.", "xp_reward": 10})
TrainingModule.objects.get_or_create(title="Public Speaking Basics", defaults={"content": "Learn to speak confidently.", "category": "Speaking"})
user, _ = User.objects.get_or_create(username="admin", defaults={"email": "admin@example.com"})
user.set_password("admin123")
user.save()
survey, _ = Survey.objects.get_or_create(title="Feedback Survey", user=user, defaults={"questions": '[{"text": "How was your experience?"}]'})
survey.set_questions([{"text": "How was your experience?"}, {"text": "What can we improve?"}])
survey.save()
exit()
EOF

    # Start Django server in background
    echo "Starting Django server..."
    python manage.py runserver 0.0.0.0:8000 &
    DJANGO_PID=$!

    echo -e "${GREEN}Django backend setup complete! Access at http://localhost:8000${NC}"
    echo "To stop the backend, run: kill $DJANGO_PID"
    echo "Django PID: $DJANGO_PID"

else
    echo -e "${RED}Invalid choice. Please run the script again and select 1 or 2.${NC}"
    exit 1
fi

echo -e "${GREEN}Django backend is ready! Open http://localhost:8000 in your browser.${NC}"
echo "To access the admin panel, go to http://localhost:8000/admin/ and log in with your superuser credentials."
echo "Note: The AI service (ai_service) must be running for full functionality. Run setup_fastapi_ai_service.sh separately."