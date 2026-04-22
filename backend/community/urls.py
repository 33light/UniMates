from django.urls import path
from . import views

urlpatterns = [
    path('posts/', views.post_list_create, name='post_list_create'),
    path('posts/<uuid:pk>/', views.post_detail_delete, name='post_detail_delete'),
    path('posts/<uuid:pk>/like/', views.post_like_toggle, name='post_like_toggle'),
    path('posts/<uuid:pk>/comments/', views.comment_list_create, name='comment_list_create'),
]
