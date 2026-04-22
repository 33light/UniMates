import uuid
from django.db import models
from django.conf import settings


class ListingType(models.TextChoices):
    BUY = 'buy', 'Buy'
    SELL = 'sell', 'Sell'
    BORROW = 'borrow', 'Borrow'
    EXCHANGE = 'exchange', 'Exchange'


class MarketplaceItem(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    seller = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='listings')
    title = models.CharField(max_length=300)
    description = models.TextField()
    image_urls = models.JSONField(default=list)
    category = models.CharField(max_length=100)
    condition = models.CharField(max_length=50, null=True, blank=True)
    type = models.CharField(max_length=10, choices=ListingType.choices, default=ListingType.SELL)
    price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    exchange_terms = models.TextField(null=True, blank=True)
    is_sold = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    rating = models.DecimalField(max_digits=3, decimal_places=2, default=5.00)
    reviews_count = models.PositiveIntegerField(default=0)

    def __str__(self):
        return self.title


class Wishlist(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='wishlist')
    marketplace_item = models.ForeignKey(MarketplaceItem, on_delete=models.CASCADE)
    added_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = [('user', 'marketplace_item')]
