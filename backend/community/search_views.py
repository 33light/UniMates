from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from django.db.models import Q
from .models import Post
from .serializers import PostSerializer
from marketplace.models import MarketplaceItem
from marketplace.serializers import MarketplaceItemSerializer
from lost_found.models import LostFoundItem
from lost_found.serializers import LostFoundItemSerializer
from users.models import User
from users.serializers import UserReadSerializer


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def global_search(request):
    try:
        q = request.GET.get('q', '').strip()
        if not q:
            return Response({'detail': 'Query parameter q is required'}, status=status.HTTP_400_BAD_REQUEST)

        posts = Post.objects.select_related('author').filter(
            Q(title__icontains=q) | Q(content__icontains=q)
        )[:10]

        items = MarketplaceItem.objects.select_related('seller').filter(
            Q(title__icontains=q) | Q(description__icontains=q)
        )[:10]

        lost_found = LostFoundItem.objects.select_related('reporter').filter(
            Q(title__icontains=q) | Q(description__icontains=q)
        )[:10]

        users = User.objects.filter(
            Q(name__icontains=q) | Q(username__icontains=q)
        )[:10]

        ctx = {'request': request}
        return Response({
            'code': status.HTTP_200_OK,
            'response': "Search results",
            'posts':     PostSerializer(posts, many=True, context=ctx).data,
            'items':     MarketplaceItemSerializer(items, many=True, context=ctx).data,
            'lostFound': LostFoundItemSerializer(lost_found, many=True, context=ctx).data,
            'users':     UserReadSerializer(users, many=True, context=ctx).data,
        })
    except Exception as e:
        return Response({'detail': str(e)}, status=status.HTTP_400_BAD_REQUEST)
