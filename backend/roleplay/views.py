from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required
from .models import Roleplay
import requests

@login_required
def roleplay_list(request):
    roleplays = Roleplay.objects.filter(user=request.user)
    if request.method == 'POST':
        scenario = request.POST.get('scenario')
        response = request.POST.get('response')
        # Call AI service
        try:
            ai_response = requests.post('http://localhost:8001/analyze_roleplay', json={
                'user_id': request.user.id,
                'scenario': scenario,
                'response': response
            }).json()
            Roleplay.objects.create(
                user=request.user,
                scenario=scenario,
                response=response,
                score=ai_response['score'],
                feedback=ai_response['feedback']
            )
        except requests.RequestException:
            pass  # Handle AI service error gracefully
        return redirect('roleplay_list')
    return render(request, 'roleplay.html', {'roleplays': roleplays})