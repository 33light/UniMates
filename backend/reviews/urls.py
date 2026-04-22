from django.urls import path
from . import views

urlpatterns = [
    path('', views.review_list_create, name='review_list_create'),
    path('has_reviewed/', views.has_reviewed, name='has_reviewed'),
]
