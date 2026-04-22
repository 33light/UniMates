from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from system_manager.upload_views import upload_file

urlpatterns = [
    path('api/v1/users/', include('users.urls')),
    path('api/v1/community/', include('community.urls')),
    path('api/v1/marketplace/', include('marketplace.urls')),
    path('api/v1/messaging/', include('messaging.urls')),
    path('api/v1/lost-found/', include('lost_found.urls')),
    path('api/v1/reviews/', include('reviews.urls')),
    path('api/v1/search/', include('system_manager.search_urls')),
    path('api/v1/upload/', upload_file),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
