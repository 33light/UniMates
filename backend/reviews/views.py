from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status

from users.models import User
from .models import Review
from .serializers import ReviewSerializer, ReviewWriteSerializer


@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def review_list_create(request):
    if request.method == 'GET':
        target_user_id = request.GET.get('target_user_id')
        if not target_user_id:
            return Response({'detail': 'target_user_id is required.'}, status=status.HTTP_400_BAD_REQUEST)
        # target_user_id may be a Firebase UID or a Django UUID — try both
        reviews = Review.objects.filter(
            target_user__firebase_uid=target_user_id
        ).order_by('-created_at')
        if not reviews.exists():
            reviews = Review.objects.filter(
                target_user__id=target_user_id
            ).order_by('-created_at') if _is_uuid(target_user_id) else reviews
        return Response(ReviewSerializer(reviews, many=True, context={'request': request}).data)

    serializer = ReviewWriteSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    target_user_id = str(serializer.validated_data['targetUserId'])
    try:
        target_user = User.objects.get(firebase_uid=target_user_id)
    except User.DoesNotExist:
        try:
            target_user = User.objects.get(pk=target_user_id)
        except (User.DoesNotExist, Exception):
            return Response({'detail': 'Target user not found.'}, status=status.HTTP_404_NOT_FOUND)

    if target_user == request.user:
        return Response({'detail': 'You cannot review yourself.'}, status=status.HTTP_400_BAD_REQUEST)

    if Review.objects.filter(reviewer=request.user, target_user=target_user).exists():
        return Response({'detail': 'You have already reviewed this user.'}, status=status.HTTP_400_BAD_REQUEST)

    review = Review.objects.create(
        reviewer=request.user,
        target_user=target_user,
        rating=serializer.validated_data['rating'],
        comment=serializer.validated_data['comment'],
    )
    return Response(ReviewSerializer(review, context={'request': request}).data, status=status.HTTP_201_CREATED)


def _is_uuid(value):
    import uuid as _uuid
    try:
        _uuid.UUID(str(value))
        return True
    except ValueError:
        return False


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def has_reviewed(request):
    target_user_id = request.GET.get('target_user_id')
    if not target_user_id:
        return Response({'detail': 'target_user_id is required.'}, status=status.HTTP_400_BAD_REQUEST)
    exists = Review.objects.filter(
        reviewer=request.user,
        target_user__firebase_uid=target_user_id
    ).exists()
    if not exists and _is_uuid(target_user_id):
        exists = Review.objects.filter(
            reviewer=request.user,
            target_user__id=target_user_id
        ).exists()
    return Response({'hasReviewed': exists})
