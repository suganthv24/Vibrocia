from django.shortcuts import render
from django.contrib.auth.decorators import login_required
from .models import UserBadge

@login_required
def tracker(request):
    badges = UserBadge.objects.filter(user=request.user)
    return render(request, 'tracker.html', {'badges': badges})