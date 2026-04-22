from rest_framework import serializers
from .models import Review


class ReviewSerializer(serializers.ModelSerializer):
    reviewerId = serializers.UUIDField(source='reviewer.id', read_only=True)
    reviewerName = serializers.CharField(source='reviewer.name', read_only=True)
    reviewerImage = serializers.SerializerMethodField()
    targetUserId = serializers.UUIDField(source='target_user.id', read_only=True)
    createdAt = serializers.DateTimeField(source='created_at', read_only=True)

    class Meta:
        model = Review
        fields = [
            'id', 'reviewerId', 'reviewerName', 'reviewerImage',
            'targetUserId', 'rating', 'comment', 'createdAt',
        ]

    def get_reviewerImage(self, obj):
        if not obj.reviewer.profile_image:
            return None
        request = self.context.get('request')
        if request:
            return request.build_absolute_uri(obj.reviewer.profile_image.url)
        return obj.reviewer.profile_image.url


class ReviewWriteSerializer(serializers.ModelSerializer):
    # CharField accepts both Firebase UIDs and Django UUIDs
    targetUserId = serializers.CharField(write_only=True)

    class Meta:
        model = Review
        fields = ['targetUserId', 'rating', 'comment']
