from django.shortcuts import render
from django.contrib.auth.decorators import login_required
from challenges.models import ChallengeProgress
from learning.models import LearningLog

@login_required
def dashboard_view(request):
    """Render the user dashboard with challenge and learning progress."""
    challenges = ChallengeProgress.objects.filter(user=request.user)
    learning_logs = LearningLog.objects.filter(user=request.user)
    return render(request, 'dashboard/dashboard.html', {
        'challenges': challenges,
        'learning_logs': learning_logs,
        'user': request.user
    })