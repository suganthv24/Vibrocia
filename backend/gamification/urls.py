from django.urls import path
from . import views

app_name = 'gamification'

urlpatterns = [
    path('', views.gamification_view, name='gamification'),
]