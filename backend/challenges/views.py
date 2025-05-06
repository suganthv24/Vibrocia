from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from .models import DailyChallenge, ChallengeProgress
from datetime import datetime

@login_required
def challenge_list(request):
    challenges = DailyChallenge.objects.all()
    progress = ChallengeProgress.objects.filter(user=request.user)
    return render(request, 'challenges.html', {'challenges': challenges, 'progress': progress})

@login_required
def complete_challenge(request, challenge_id):
    challenge = DailyChallenge.objects.get(id=challenge_id)
    progress, created = ChallengeProgress.objects.get_or_create(
        user=request.user,
        challenge=challenge,
        defaults={'completed': True, 'completed_at': datetime.now()}
    )
    if not created:
        progress.completed = True
        progress.completed_at = datetime.now()
        progress.save()
    return redirect('challenge_list')