from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import Message


@receiver(post_save, sender=Message)
def update_conversation_last_message(sender, instance, created, **kwargs):
    if created:
        conv = instance.conversation
        conv.last_message = instance.content
        conv.last_message_time = instance.timestamp
        conv.save(update_fields=['last_message', 'last_message_time'])
