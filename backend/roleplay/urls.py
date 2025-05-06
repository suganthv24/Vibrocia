from django.urls import path
from . import views

urlpatterns = [
    path('', views.roleplay_list, name='roleplay_list'),
]