from django.urls import path
from . import views

urlpatterns = [
    path('', views.item_list_create, name='lf_item_list_create'),
    path('<uuid:pk>/', views.item_detail_update_delete, name='lf_item_detail_update_delete'),
    path('<uuid:pk>/resolve/', views.item_resolve, name='lf_item_resolve'),
]
