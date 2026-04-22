from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status

from system_manager.helper import PageNumberPagination
from users.models import User
from .models import LostFoundItem
from .serializers import LostFoundItemSerializer, LostFoundItemWriteSerializer


@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def item_list_create(request):
    if request.method == 'GET':
        queryset = LostFoundItem.objects.all().order_by('-created_at')
        type_ = request.GET.get('type')
        q = request.GET.get('q')
        resolved = request.GET.get('resolved')
        if type_:
            queryset = queryset.filter(type=type_)
        if q:
            queryset = queryset.filter(title__icontains=q)
        if resolved is not None:
            queryset = queryset.filter(is_resolved=resolved.lower() == 'true')
        paginator = PageNumberPagination()
        page = paginator.paginate_queryset(queryset, request)
        return paginator.get_paginated_response(
            LostFoundItemSerializer(page, many=True, context={'request': request}).data
        )

    serializer = LostFoundItemWriteSerializer(data=request.data)
    if serializer.is_valid():
        item = serializer.save(reporter=request.user)
        return Response(LostFoundItemSerializer(item, context={'request': request}).data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET', 'PATCH', 'DELETE'])
@permission_classes([IsAuthenticated])
def item_detail_update_delete(request, pk):
    try:
        item = LostFoundItem.objects.get(pk=pk)
    except LostFoundItem.DoesNotExist:
        return Response({'detail': 'Item not found.'}, status=status.HTTP_404_NOT_FOUND)

    if request.method == 'GET':
        return Response(LostFoundItemSerializer(item, context={'request': request}).data)

    if item.reporter != request.user:
        return Response({'detail': 'Not allowed.'}, status=status.HTTP_403_FORBIDDEN)

    if request.method == 'PATCH':
        serializer = LostFoundItemWriteSerializer(item, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(LostFoundItemSerializer(item, context={'request': request}).data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    item.delete()
    return Response(status=status.HTTP_204_NO_CONTENT)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def item_resolve(request, pk):
    try:
        item = LostFoundItem.objects.get(pk=pk)
    except LostFoundItem.DoesNotExist:
        return Response({'detail': 'Item not found.'}, status=status.HTTP_404_NOT_FOUND)
    if item.reporter != request.user:
        return Response({'detail': 'Not allowed.'}, status=status.HTTP_403_FORBIDDEN)
    resolved_by_id = request.data.get('resolvedById')
    resolved_by = None
    if resolved_by_id:
        try:
            resolved_by = User.objects.get(pk=resolved_by_id)
        except User.DoesNotExist:
            return Response({'detail': 'Resolved-by user not found.'}, status=status.HTTP_404_NOT_FOUND)
    item.is_resolved = True
    item.resolved_by = resolved_by
    item.save()
    return Response(LostFoundItemSerializer(item, context={'request': request}).data)
