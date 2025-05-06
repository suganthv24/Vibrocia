from django.db import models
from accounts.models import User
import json

class Survey(models.Model):
    title = models.CharField(max_length=255, default="Untitled Survey")
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='surveys')
    questions = models.TextField(default='[]')  # JSON string
    confidence_level = models.FloatField(default=0.0)  # New field for confidence score
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def set_questions(self, questions_list):
        """Helper to store questions as JSON."""
        self.questions = json.dumps(questions_list)

    def get_questions(self):
        """Helper to retrieve questions as Python list."""
        return json.loads(self.questions) if self.questions else []

    def __str__(self):
        return self.title

class SurveyResponse(models.Model):
    survey = models.ForeignKey(Survey, on_delete=models.CASCADE, related_name='responses')
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='survey_responses')
    answers = models.TextField(default='{}')  # JSON object
    submitted_at = models.DateTimeField(auto_now_add=True)

    def set_answers(self, answers_dict):
        """Helper to store answers as JSON."""
        self.answers = json.dumps(answers_dict)

    def get_answers(self):
        """Helper to retrieve answers as Python dict."""
        return json.loads(self.answers) if self.answers else {}

    def __str__(self):
        return f"Response to {self.survey.title} by {self.user.username}"