from rest_framework import serializers
from .models import Post, Comment
from users.serializers import UserSerializer


class CommentSerializer(serializers.ModelSerializer):
    author = UserSerializer(read_only=True)
    postId = serializers.UUIDField(source='post_id', read_only=True)
    createdAt = serializers.DateTimeField(source='created_at', read_only=True)

    class Meta:
        model = Comment
        fields = ['id', 'postId', 'author', 'content', 'createdAt']


class CommentWriteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Comment
        fields = ['content']


class PostReadSerializer(serializers.ModelSerializer):
    author = UserSerializer(read_only=True)
    imageUrls = serializers.JSONField(source='image_urls', read_only=True)
    likesCount = serializers.IntegerField(source='likes_count', read_only=True)
    commentsCount = serializers.IntegerField(source='comments_count', read_only=True)
    createdAt = serializers.DateTimeField(source='created_at', read_only=True)
    isLikedByCurrentUser = serializers.SerializerMethodField()
    isEvent = serializers.BooleanField(source='is_event', read_only=True)
    eventDate = serializers.DateTimeField(source='event_date', read_only=True)
    eventLocation = serializers.CharField(source='event_location', read_only=True)

    class Meta:
        model = Post
        fields = [
            'id', 'title', 'content', 'author', 'imageUrls',
            'likesCount', 'commentsCount', 'createdAt',
            'isLikedByCurrentUser', 'isEvent', 'eventDate', 'eventLocation',
        ]

    def get_isLikedByCurrentUser(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return obj.likes.filter(user=request.user).exists()
        return False


class PostWriteSerializer(serializers.ModelSerializer):
    imageUrls = serializers.JSONField(source='image_urls', required=False)
    isEvent = serializers.BooleanField(source='is_event', required=False)
    eventDate = serializers.DateTimeField(source='event_date', required=False, allow_null=True)
    eventLocation = serializers.CharField(source='event_location', required=False, allow_null=True, allow_blank=True)

    class Meta:
        model = Post
        fields = ['title', 'content', 'imageUrls', 'isEvent', 'eventDate', 'eventLocation']
