# from django.urls import path
# from . import views

# urlpatterns = [
#     path('', views.learning_list, name='learning_list'),
#     path('complete/<int:module_id>/', views.complete_module, name='complete_module'),
# ]

from django.urls import path
from . import views

app_name = 'chatbot'

urlpatterns = [
    path('', views.ChatbotView.as_view(), name='chatbot'),
]