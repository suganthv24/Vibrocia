from django.urls import path
from . import views

urlpatterns = [
    path('', views.challenge_list, name='challenge_list'),
    path('complete/<int:challenge_id>/', views.complete_challenge, name='complete_challenge'),
]