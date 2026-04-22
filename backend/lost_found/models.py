import uuid
from django.db import models
from django.conf import settings


class LostFoundType(models.TextChoices):
    LOST = 'lost', 'Lost'
    FOUND = 'found', 'Found'


class LostFoundItem(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    reporter = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='lost_found_reports')
    title = models.CharField(max_length=300)
    description = models.TextField()
    location = models.CharField(max_length=300)
    category = models.CharField(max_length=100, null=True, blank=True)
    item_date = models.DateField()
    image_urls = models.JSONField(default=list)
    type = models.CharField(max_length=5, choices=LostFoundType.choices)
    is_resolved = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    resolved_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, null=True, blank=True,
        on_delete=models.SET_NULL, related_name='resolved_items'
    )

    def __str__(self):
        return f"[{self.type}] {self.title}"
