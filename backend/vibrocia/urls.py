from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('accounts/', include('accounts.urls')),
    path('survey/', include('survey.urls')),
    path('', include('dashboard.urls')),
    path('roleplay/', include('roleplay.urls')),
    path('chatbot/', include('chatbot.urls')),
    path('challenges/', include('challenges.urls')),
    path('learning/', include('learning.urls')),
    path('gamification/', include('gamification.urls')),
]