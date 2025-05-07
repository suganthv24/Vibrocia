from django.urls import path
from . import views

app_name = 'roleplay'

urlpatterns = [
    path('', views.roleplay_view, name='roleplay'),
]