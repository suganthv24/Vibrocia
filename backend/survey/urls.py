from django.urls import path
from . import views

app_name = 'survey'

urlpatterns = [
    path('', views.SurveyCreateView.as_view(), name='survey_create'),
]