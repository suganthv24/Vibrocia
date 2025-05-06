from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('', include('dashboard.urls')),
    path('admin/', admin.site.urls),
    path('accounts/', include('accounts.urls')),
    path('survey/', include('survey.urls')),
    path('dashboard/', include('dashboard.urls')),
    path('roleplay/', include('roleplay.urls')),
    path('chatbot/', include('chatbot.urls')),
    path('challenges/', include('challenges.urls')),
    path('learning/', include('learning.urls')),
    path('gamification/', include('gamification.urls')),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)