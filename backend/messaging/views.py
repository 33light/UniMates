from django.db.models import Q
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status

from users.models import User
from .models import Conversation, Message
from .serializers import ConversationSerializer, MessageSerializer, MessageWriteSerializer


@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def conversation_list_create(request):
    if request.method == 'GET':
        conversations = Conversation.objects.filter(
            Q(user1=request.user) | Q(user2=request.user)
        ).order_by('-last_message_time')
        return Response(ConversationSerializer(conversations, many=True, context={'request': request}).data)

    other_user_id = request.data.get('otherUserId')
    if not other_user_id:
        return Response({'detail': 'otherUserId is required.'}, status=status.HTTP_400_BAD_REQUEST)
    try:
        other_user = User.objects.get(pk=other_user_id)
    except User.DoesNotExist:
        return Response({'detail': 'User not found.'}, status=status.HTTP_404_NOT_FOUND)

    u1, u2 = sorted([request.user, other_user], key=lambda u: str(u.id))
    conv, created = Conversation.objects.get_or_create(user1=u1, user2=u2)
    code = status.HTTP_201_CREATED if created else status.HTTP_200_OK
    return Response(ConversationSerializer(conv, context={'request': request}).data, status=code)


@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def message_list_create(request, pk):
    try:
        conv = Conversation.objects.get(pk=pk)
    except Conversation.DoesNotExist:
        return Response({'detail': 'Conversation not found.'}, status=status.HTTP_404_NOT_FOUND)

    if request.user not in (conv.user1, conv.user2):
        return Response({'detail': 'Not allowed.'}, status=status.HTTP_403_FORBIDDEN)

    if request.method == 'GET':
        messages = conv.messages.all().order_by('timestamp')
        return Response(MessageSerializer(messages, many=True, context={'request': request}).data)

    serializer = MessageWriteSerializer(data=request.data)
    if serializer.is_valid():
        msg = serializer.save(conversation=conv, sender=request.user)
        return Response(MessageSerializer(msg, context={'request': request}).data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_conversation(request, pk):
    try:
        conv = Conversation.objects.get(pk=pk)
    except Conversation.DoesNotExist:
        return Response({'detail': 'Conversation not found.'}, status=status.HTTP_404_NOT_FOUND)
    if request.user not in (conv.user1, conv.user2):
        return Response({'detail': 'Not allowed.'}, status=status.HTTP_403_FORBIDDEN)
    conv.delete()
    return Response(status=status.HTTP_204_NO_CONTENT)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def mark_read(request, pk):
    try:
        conv = Conversation.objects.get(pk=pk)
    except Conversation.DoesNotExist:
        return Response({'detail': 'Conversation not found.'}, status=status.HTTP_404_NOT_FOUND)
    if request.user not in (conv.user1, conv.user2):
        return Response({'detail': 'Not allowed.'}, status=status.HTTP_403_FORBIDDEN)
    conv.messages.exclude(sender=request.user).update(is_read=True)
    return Response({'detail': 'Messages marked as read.'})
