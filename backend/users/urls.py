from django.urls import path
from . import views

urlpatterns = [
    path('me/', views.me, name='user_me'),
    path('me/avatar/', views.me_avatar, name='user_me_avatar'),
    path('search/', views.user_search, name='user_search'),
    path('<uuid:pk>/', views.user_detail, name='user_detail'),
    path('firebase/<str:firebase_uid>/', views.user_by_firebase_uid, name='user_by_firebase_uid'),
]
