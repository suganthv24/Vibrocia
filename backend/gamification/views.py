from django.shortcuts import render
from django.contrib.auth.decorators import login_required
from .models import UserBadge

@login_required
def gamification_view(request):
    """Render the gamification page with user badges and points."""
    badges = UserBadge.objects.filter(user=request.user)
    return render(request, 'gamification/gamification.html', {
        'badges': badges,
        'user': request.user
    })