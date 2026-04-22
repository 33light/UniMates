from django.urls import path
from . import views

urlpatterns = [
    path('items/', views.item_list_create, name='item_list_create'),
    path('items/my/', views.my_items, name='my_items'),
    path('items/<uuid:pk>/', views.item_detail_update_delete, name='item_detail_update_delete'),
    path('items/<uuid:pk>/mark_sold/', views.item_mark_sold, name='item_mark_sold'),
    path('wishlist/', views.wishlist, name='wishlist_list'),
    path('wishlist/<uuid:pk>/toggle/', views.wishlist, name='wishlist_toggle'),
]
