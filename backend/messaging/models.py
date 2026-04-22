import uuid
from django.db import models
from django.conf import settings


class Conversation(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user1 = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='conv_as_user1')
    user2 = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='conv_as_user2')
    last_message = models.TextField(blank=True)
    last_message_time = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = [('user1', 'user2')]

    def __str__(self):
        return f"Conversation {self.user1} <-> {self.user2}"


class Message(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    conversation = models.ForeignKey(Conversation, on_delete=models.CASCADE, related_name='messages')
    sender = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    content = models.TextField()
    image_urls = models.JSONField(default=list)
    timestamp = models.DateTimeField(auto_now_add=True)
    is_read = models.BooleanField(default=False)

    def __str__(self):
        return f"Message from {self.sender} in {self.conversation_id}"
