from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from .models import Survey
from django.contrib.auth import get_user_model
import json

User = get_user_model()

class SurveyCreateView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        data = request.data
        title = data.get('title', 'Untitled Survey')
        questions = data.get('questions', [])
        confidence_level = data.get('confidence_level', 0.0)

        try:
            survey = Survey.objects.create(
                title=title,
                user=request.user,
                questions=json.dumps(questions),
                confidence_level=float(confidence_level)
            )
            return Response({
                'id': survey.id,
                'title': survey.title,
                'questions': survey.get_questions(),
                'confidence_level': survey.confidence_level,
                'created_at': survey.created_at
            }, status=status.HTTP_201_CREATED)
        except ValueError as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)