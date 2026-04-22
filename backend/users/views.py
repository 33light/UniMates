from rest_framework.decorators import api_view, permission_classes, parser_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.parsers import MultiPartParser
from rest_framework.response import Response
from rest_framework import status

from .models import User
from .serializers import UserSerializer, UserUpdateSerializer


@api_view(['GET', 'PATCH'])
@permission_classes([IsAuthenticated])
def me(request):
    if request.method == 'GET':
        serializer = UserSerializer(request.user, context={'request': request})
        return Response(serializer.data)

    serializer = UserUpdateSerializer(request.user, data=request.data, partial=True)
    if serializer.is_valid():
        serializer.save()
        return Response(UserSerializer(request.user, context={'request': request}).data)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['PATCH'])
@permission_classes([IsAuthenticated])
@parser_classes([MultiPartParser])
def me_avatar(request):
    image = request.FILES.get('image')
    if not image:
        return Response({'detail': 'No image provided.'}, status=status.HTTP_400_BAD_REQUEST)
    request.user.profile_image = image
    request.user.save()
    serializer = UserSerializer(request.user, context={'request': request})
    return Response({'profileImageUrl': serializer.data['profileImageUrl']})


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def user_detail(request, pk):
    try:
        user = User.objects.get(pk=pk)
    except User.DoesNotExist:
        return Response({'detail': 'User not found.'}, status=status.HTTP_404_NOT_FOUND)
    return Response(UserSerializer(user, context={'request': request}).data)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def user_by_firebase_uid(request, firebase_uid):
    """Look up a user by their Firebase UID (useful when you only have the Firebase UID)."""
    try:
        user = User.objects.get(firebase_uid=firebase_uid)
    except User.DoesNotExist:
        return Response({'detail': 'User not found.'}, status=status.HTTP_404_NOT_FOUND)
    return Response(UserSerializer(user, context={'request': request}).data)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def user_search(request):
    q = request.GET.get('q', '').strip()
    if not q:
        return Response({'detail': 'q parameter required.'}, status=status.HTTP_400_BAD_REQUEST)
    users = (
        User.objects.filter(name__icontains=q) |
        User.objects.filter(username__icontains=q)
    ).distinct()
    return Response(UserSerializer(users, many=True, context={'request': request}).data)
