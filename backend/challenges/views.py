from django.shortcuts import render
from .models import DailyChallenge

def challenge_list(request):
    """Render the list of daily challenges."""
    challenges = DailyChallenge.objects.all()
    return render(request, 'challenges/challenge_list.html', {'challenges': challenges})