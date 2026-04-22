from django.urls import path
from . import views

urlpatterns = [
    path('conversations/', views.conversation_list_create, name='conversation_list_create'),
    path('conversations/<uuid:pk>/', views.delete_conversation, name='delete_conversation'),
    path('conversations/<uuid:pk>/messages/', views.message_list_create, name='message_list_create'),
    path('conversations/<uuid:pk>/mark_read/', views.mark_read, name='mark_read'),
]
