from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status

from community.models import Post
from marketplace.models import MarketplaceItem
from lost_found.models import LostFoundItem
from users.models import User

from community.serializers import PostReadSerializer
from marketplace.serializers import MarketplaceItemSerializer
from lost_found.serializers import LostFoundItemSerializer
from users.serializers import UserSerializer


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def global_search(request):
    q = request.GET.get('q', '').strip()
    if not q:
        return Response({'detail': 'q parameter is required.'}, status=status.HTTP_400_BAD_REQUEST)

    posts = Post.objects.filter(title__icontains=q)[:10]
    items = MarketplaceItem.objects.filter(title__icontains=q)[:10]
    lost_found = LostFoundItem.objects.filter(title__icontains=q)[:10]
    users = User.objects.filter(name__icontains=q)[:10]

    context = {'request': request}
    return Response({
        'posts': PostReadSerializer(posts, many=True, context=context).data,
        'items': MarketplaceItemSerializer(items, many=True, context=context).data,
        'lostFound': LostFoundItemSerializer(lost_found, many=True, context=context).data,
        'users': UserSerializer(users, many=True, context=context).data,
    })
