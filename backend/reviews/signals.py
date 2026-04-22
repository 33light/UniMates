from django.db.models.signals import post_save
from django.dispatch import receiver
from django.db.models import Avg
from .models import Review


@receiver(post_save, sender=Review)
def update_user_rating(sender, instance, **kwargs):
    target = instance.target_user
    agg = Review.objects.filter(target_user=target).aggregate(avg=Avg('rating'))
    target.rating = agg['avg'] or 5.00
    target.reviews_count = Review.objects.filter(target_user=target).count()
    target.save(update_fields=['rating', 'reviews_count'])
