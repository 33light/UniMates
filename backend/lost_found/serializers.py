from rest_framework import serializers
from .models import LostFoundItem


class LostFoundItemSerializer(serializers.ModelSerializer):
    reporterId = serializers.UUIDField(source='reporter.id', read_only=True)
    reporterName = serializers.CharField(source='reporter.name', read_only=True)
    reporterImage = serializers.SerializerMethodField()
    itemDate = serializers.DateField(source='item_date', read_only=True)
    imageUrls = serializers.JSONField(source='image_urls', read_only=True)
    isResolved = serializers.BooleanField(source='is_resolved', read_only=True)
    createdAt = serializers.DateTimeField(source='created_at', read_only=True)
    resolvedBy = serializers.SerializerMethodField()

    class Meta:
        model = LostFoundItem
        fields = [
            'id', 'reporterId', 'reporterName', 'reporterImage',
            'title', 'description', 'location', 'category',
            'itemDate', 'imageUrls', 'type', 'isResolved', 'createdAt', 'resolvedBy',
        ]

    def get_reporterImage(self, obj):
        if not obj.reporter.profile_image:
            return None
        request = self.context.get('request')
        if request:
            return request.build_absolute_uri(obj.reporter.profile_image.url)
        return obj.reporter.profile_image.url

    def get_resolvedBy(self, obj):
        if not obj.resolved_by:
            return None
        return str(obj.resolved_by.id)


class LostFoundItemWriteSerializer(serializers.ModelSerializer):
    imageUrls = serializers.JSONField(source='image_urls', required=False)
    itemDate = serializers.DateField(source='item_date')

    class Meta:
        model = LostFoundItem
        fields = ['title', 'description', 'location', 'category', 'itemDate', 'type', 'imageUrls']
