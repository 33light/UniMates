from rest_framework import serializers
from .models import Conversation, Message


class ConversationSerializer(serializers.ModelSerializer):
    userId1 = serializers.UUIDField(source='user1.id', read_only=True)
    userId2 = serializers.UUIDField(source='user2.id', read_only=True)
    user1Name = serializers.CharField(source='user1.name', read_only=True)
    user2Name = serializers.CharField(source='user2.name', read_only=True)
    user1Image = serializers.SerializerMethodField()
    user2Image = serializers.SerializerMethodField()
    lastMessage = serializers.CharField(source='last_message', read_only=True)
    lastMessageTime = serializers.DateTimeField(source='last_message_time', read_only=True)
    unreadCount = serializers.SerializerMethodField()

    class Meta:
        model = Conversation
        fields = [
            'id', 'userId1', 'userId2',
            'user1Name', 'user2Name', 'user1Image', 'user2Image',
            'lastMessage', 'lastMessageTime', 'unreadCount',
        ]

    def _image_url(self, user):
        if not user.profile_image:
            return None
        request = self.context.get('request')
        if request:
            return request.build_absolute_uri(user.profile_image.url)
        return user.profile_image.url

    def get_user1Image(self, obj):
        return self._image_url(obj.user1)

    def get_user2Image(self, obj):
        return self._image_url(obj.user2)

    def get_unreadCount(self, obj):
        request = self.context.get('request')
        if not request:
            return 0
        return obj.messages.filter(is_read=False).exclude(sender=request.user).count()


class MessageSerializer(serializers.ModelSerializer):
    conversationId = serializers.UUIDField(source='conversation_id', read_only=True)
    senderId = serializers.UUIDField(source='sender.id', read_only=True)
    senderName = serializers.CharField(source='sender.name', read_only=True)
    senderImage = serializers.SerializerMethodField()
    imageUrls = serializers.JSONField(source='image_urls', read_only=True)
    isRead = serializers.BooleanField(source='is_read', read_only=True)

    class Meta:
        model = Message
        fields = [
            'id', 'conversationId', 'senderId', 'senderName', 'senderImage',
            'content', 'timestamp', 'isRead', 'imageUrls',
        ]

    def get_senderImage(self, obj):
        if not obj.sender.profile_image:
            return None
        request = self.context.get('request')
        if request:
            return request.build_absolute_uri(obj.sender.profile_image.url)
        return obj.sender.profile_image.url


class MessageWriteSerializer(serializers.ModelSerializer):
    imageUrls = serializers.JSONField(source='image_urls', required=False)

    class Meta:
        model = Message
        fields = ['content', 'imageUrls']
