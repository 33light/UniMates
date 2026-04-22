from rest_framework.pagination import PageNumberPagination as DRFPagination
from rest_framework.permissions import BasePermission


class PageNumberPagination(DRFPagination):
    """
    Flutter sends ?page=0 for the first page.
    DRF is 1-indexed internally, so we add 1.
    """
    page_size = 10
    page_size_query_param = 'page_size'
    page_query_param = 'page'

    def get_page_number(self, request, paginator):
        try:
            return int(request.query_params.get(self.page_query_param, 0)) + 1
        except (ValueError, TypeError):
            return 1


class IsOwner(BasePermission):
    """Object-level: only the owner can modify."""

    def has_object_permission(self, request, view, obj):
        for field in ('author', 'seller', 'reporter', 'reviewer', 'user', 'sender'):
            if hasattr(obj, field):
                return getattr(obj, field) == request.user
        return False
