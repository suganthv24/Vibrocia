# from django.shortcuts import render, redirect
# from django.contrib.auth.decorators import login_required
# from .models import TrainingModule, ModuleProgress
# from datetime import datetime

# @login_required
# def learning_list(request):
#     modules = TrainingModule.objects.all()
#     progress = ModuleProgress.objects.filter(user=request.user)
#     return render(request, 'learning.html', {'modules': modules, 'progress': progress})

# @login_required
# def complete_module(request, module_id):
#     module = TrainingModule.objects.get(id=module_id)
#     progress, created = ModuleProgress.objects.get_or_create(
#         user=request.user,
#         module=module,
#         defaults={'completed': True, 'completed_at': datetime.now()}
#     )
#     if not created:
#         progress.completed = True
#         progress.completed_at = datetime.now()
#         progress.save()
#     return redirect('learning_list')

import requests
import logging
from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated

# Configure logging
logger = logging.getLogger(__name__)

class ChatbotView(APIView):
    permission_classes = [IsAuthenticated]
    template_name = 'chatbot/chatbot.html'

    def get(self, request):
        """Render the chatbot interface."""
        return render(request, self.template_name, {'message': None, 'error': None})

    def post(self, request):
        """Handle chatbot message and forward to AI service."""
        user_message = request.data.get('message')
        if not user_message:
            logger.error("No message provided in POST request")
            return Response({'error': 'Message is required'}, status=status.HTTP_400_BAD_REQUEST)

        # AI service URL
        ai_service_url = 'http://localhost:8001/chatbot_response' if not request.session.get('DOCKER_COMPOSE') else 'http://ai_service:8001/chatbot_response'

        try:
            # Send request to AI service
            response = requests.post(
                ai_service_url,
                json={'message': user_message},
                timeout=5
            )
            response.raise_for_status()  # Raise exception for 4xx/5xx status
            ai_response = response.json().get('response', 'No response from AI service')
            logger.info(f"AI service response: {ai_response}")
            return Response({'response': ai_response}, status=status.HTTP_200_OK)

        except requests.ConnectionError as e:
            logger.error(f"Failed to connect to AI service: {str(e)}")
            return Response(
                {'error': 'Unable to connect to AI service. Please try again later.'},
                status=status.HTTP_503_SERVICE_UNAVAILABLE
            )
        except requests.Timeout:
            logger.error("AI service request timed out")
            return Response(
                {'error': 'AI service request timed out.'},
                status=status.HTTP_504_GATEWAY_TIMEOUT
            )
        except requests.HTTPError as e:
            logger.error(f"AI service returned an error: {str(e)}")
            return Response(
                {'error': 'AI service error.'},
                status=status.HTTP_502_BAD_GATEWAY
            )
        except ValueError as e:
            logger.error(f"Invalid response from AI service: {str(e)}")
            return Response(
                {'error': 'Invalid response from AI service.'},
                status=status.HTTP_502_BAD_GATEWAY
            )