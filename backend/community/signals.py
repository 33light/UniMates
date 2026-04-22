from django.db import models
from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from .models import PostLike, Comment


@receiver(post_save, sender=PostLike)
def increment_likes(sender, instance, created, **kwargs):
    if created:
        Post = instance.post.__class__
        Post.objects.filter(pk=instance.post_id).update(
            likes_count=models.F('likes_count') + 1
        )


@receiver(post_delete, sender=PostLike)
def decrement_likes(sender, instance, **kwargs):
    Post = instance.post.__class__
    Post.objects.filter(pk=instance.post_id).update(
        likes_count=models.F('likes_count') - 1
    )


@receiver(post_save, sender=Comment)
def increment_comments(sender, instance, created, **kwargs):
    if created:
        Post = instance.post.__class__
        Post.objects.filter(pk=instance.post_id).update(
            comments_count=models.F('comments_count') + 1
        )
