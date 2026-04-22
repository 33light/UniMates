from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status

from system_manager.helper import PageNumberPagination
from .models import MarketplaceItem, Wishlist
from .serializers import MarketplaceItemSerializer, MarketplaceItemWriteSerializer


@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def item_list_create(request):
    if request.method == 'GET':
        queryset = MarketplaceItem.objects.all().order_by('-created_at')
        category = request.GET.get('category')
        type_ = request.GET.get('type')
        min_price = request.GET.get('min_price')
        max_price = request.GET.get('max_price')
        q = request.GET.get('q')
        if category:
            queryset = queryset.filter(category__icontains=category)
        if type_:
            queryset = queryset.filter(type=type_)
        if min_price:
            queryset = queryset.filter(price__gte=min_price)
        if max_price:
            queryset = queryset.filter(price__lte=max_price)
        if q:
            queryset = queryset.filter(title__icontains=q)
        paginator = PageNumberPagination()
        page = paginator.paginate_queryset(queryset, request)
        return paginator.get_paginated_response(
            MarketplaceItemSerializer(page, many=True, context={'request': request}).data
        )

    serializer = MarketplaceItemWriteSerializer(data=request.data)
    if serializer.is_valid():
        item = serializer.save(seller=request.user)
        return Response(MarketplaceItemSerializer(item, context={'request': request}).data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET', 'PATCH', 'DELETE'])
@permission_classes([IsAuthenticated])
def item_detail_update_delete(request, pk):
    try:
        item = MarketplaceItem.objects.get(pk=pk)
    except MarketplaceItem.DoesNotExist:
        return Response({'detail': 'Item not found.'}, status=status.HTTP_404_NOT_FOUND)

    if request.method == 'GET':
        return Response(MarketplaceItemSerializer(item, context={'request': request}).data)

    if item.seller != request.user:
        return Response({'detail': 'Not allowed.'}, status=status.HTTP_403_FORBIDDEN)

    if request.method == 'PATCH':
        serializer = MarketplaceItemWriteSerializer(item, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(MarketplaceItemSerializer(item, context={'request': request}).data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    item.delete()
    return Response(status=status.HTTP_204_NO_CONTENT)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def item_mark_sold(request, pk):
    try:
        item = MarketplaceItem.objects.get(pk=pk)
    except MarketplaceItem.DoesNotExist:
        return Response({'detail': 'Item not found.'}, status=status.HTTP_404_NOT_FOUND)
    if item.seller != request.user:
        return Response({'detail': 'Not allowed.'}, status=status.HTTP_403_FORBIDDEN)
    item.is_sold = True
    item.save()
    return Response(MarketplaceItemSerializer(item, context={'request': request}).data)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def my_items(request):
    queryset = MarketplaceItem.objects.filter(seller=request.user).order_by('-created_at')
    paginator = PageNumberPagination()
    page = paginator.paginate_queryset(queryset, request)
    return paginator.get_paginated_response(
        MarketplaceItemSerializer(page, many=True, context={'request': request}).data
    )


@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def wishlist(request, pk=None):
    if request.method == 'GET':
        items = MarketplaceItem.objects.filter(
            wishlist__user=request.user
        ).order_by('-wishlist__added_at')
        return Response(MarketplaceItemSerializer(items, many=True, context={'request': request}).data)

    # POST — toggle
    try:
        item = MarketplaceItem.objects.get(pk=pk)
    except MarketplaceItem.DoesNotExist:
        return Response({'detail': 'Item not found.'}, status=status.HTTP_404_NOT_FOUND)
    entry = Wishlist.objects.filter(user=request.user, marketplace_item=item).first()
    if entry:
        entry.delete()
        return Response({'wishlisted': False})
    Wishlist.objects.create(user=request.user, marketplace_item=item)
    return Response({'wishlisted': True})
