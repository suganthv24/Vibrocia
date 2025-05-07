from django.shortcuts import render
from .models import TrainingModule

def learning_view(request):
    modules = TrainingModule.objects.all()
    return render(request, 'learning/learning.html', {'modules': modules})