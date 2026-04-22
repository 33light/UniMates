from rest_framework import serializers
from .models import User


class UserSerializer(serializers.ModelSerializer):
    profileImageUrl = serializers.SerializerMethodField()
    isVerified = serializers.BooleanField(source='is_verified', read_only=True)
    joinDate = serializers.DateTimeField(source='join_date', read_only=True)
    reviewsCount = serializers.IntegerField(source='reviews_count', read_only=True)

    class Meta:
        model = User
        fields = [
            'id', 'name', 'username', 'email', 'profileImageUrl',
            'university', 'isVerified', 'joinDate', 'bio', 'rating', 'reviewsCount',
        ]

    def get_profileImageUrl(self, obj):
        if not obj.profile_image:
            return None
        request = self.context.get('request')
        if request:
            return request.build_absolute_uri(obj.profile_image.url)
        return obj.profile_image.url


class UserUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['name', 'username', 'bio', 'university', 'fcm_token']
