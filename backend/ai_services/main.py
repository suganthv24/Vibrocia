from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import requests
from ai_engine import analyze_text


app = FastAPI()

class RoleplayInput(BaseModel):
    user_id: int
    scenario: str
    response: str

class ChatbotInput(BaseModel):
    user_id: int
    message: str

class ChatbotRequest(BaseModel):
    message: str


@app.post("/analyze_roleplay")
async def analyze_roleplay(data: RoleplayInput):
    # Use AI engine for analysis
    result = analyze_text(data.response)
    try:
        # Optionally update user XP in Django backend
        response = requests.post('http://web:8000/gamification/update_xp/', json={
            'user_id': data.user_id,
            'xp': result['score']
        })
        if response.status_code != 200:
            print(f"Failed to update XP: {response.text}")
    except requests.RequestException as e:
        print(f"Error contacting Django backend: {e}")
    return {"score": result['score'], "feedback": result['feedback']}




@app.post("/chatbot_response")
async def chatbot_response(request: ChatbotRequest):
    """Handle chatbot message and return a response."""
    user_message = request.message
    if not user_message:
        raise HTTPException(status_code=400, detail="Message is required")

    # Placeholder AI response (replace with actual AI model integration)
    response = f"Echo: {user_message}"  # Mock response for testing
    return {"response": response}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}