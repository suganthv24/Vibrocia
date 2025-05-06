from django.shortcuts import render
from django.contrib.auth.decorators import login_required
from challenges.models import ChallengeProgress
from learning.models import ModuleProgress

@login_required
def dashboard(request):
    challenges = ChallengeProgress.objects.filter(user=request.user)
    modules = ModuleProgress.objects.filter(user=request.user)
    return render(request, 'dashboard.html', {
        'challenges': challenges,
        'modules': modules,
        'user': request.user
    })