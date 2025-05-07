from django.shortcuts import render

def survey_list(request):
    return render(request, 'survey/survey_list.html', {})