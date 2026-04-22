from rest_framework import serializers
from .models import MarketplaceItem


class MarketplaceItemSerializer(serializers.ModelSerializer):
    userId = serializers.UUIDField(source='seller.id', read_only=True)
    sellerName = serializers.CharField(source='seller.name', read_only=True)
    sellerImage = serializers.SerializerMethodField()
    imageUrls = serializers.JSONField(source='image_urls', read_only=True)
    exchangeTerms = serializers.CharField(source='exchange_terms', read_only=True)
    isSold = serializers.BooleanField(source='is_sold', read_only=True)
    createdAt = serializers.DateTimeField(source='created_at', read_only=True)
    reviewsCount = serializers.IntegerField(source='reviews_count', read_only=True)

    class Meta:
        model = MarketplaceItem
        fields = [
            'id', 'userId', 'sellerName', 'sellerImage',
            'title', 'description', 'imageUrls', 'category',
            'condition', 'type', 'price', 'exchangeTerms',
            'createdAt', 'isSold', 'rating', 'reviewsCount',
        ]

    def get_sellerImage(self, obj):
        if not obj.seller.profile_image:
            return None
        request = self.context.get('request')
        if request:
            return request.build_absolute_uri(obj.seller.profile_image.url)
        return obj.seller.profile_image.url


class MarketplaceItemWriteSerializer(serializers.ModelSerializer):
    imageUrls = serializers.JSONField(source='image_urls', required=False)
    exchangeTerms = serializers.CharField(source='exchange_terms', required=False, allow_null=True, allow_blank=True)

    class Meta:
        model = MarketplaceItem
        fields = ['title', 'description', 'category', 'condition', 'type', 'price', 'exchangeTerms', 'imageUrls']
