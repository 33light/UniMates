import uuid
from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager


class UserManager(BaseUserManager):
    def create_user(self, firebase_uid, email='', name='', **extra_fields):
        user = self.model(firebase_uid=firebase_uid, email=email, name=name, **extra_fields)
        user.set_unusable_password()
        user.save(using=self._db)
        return user


class User(AbstractBaseUser):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    firebase_uid = models.CharField(max_length=128, unique=True)
    name = models.CharField(max_length=255)
    username = models.CharField(max_length=100, unique=True, blank=True, null=True)
    email = models.EmailField(unique=True)
    profile_image = models.ImageField(upload_to='profiles/', null=True, blank=True)
    university = models.CharField(max_length=255, blank=True)
    is_verified = models.BooleanField(default=False)
    join_date = models.DateTimeField(auto_now_add=True)
    bio = models.TextField(blank=True, null=True)
    rating = models.DecimalField(max_digits=3, decimal_places=2, default=5.00)
    reviews_count = models.PositiveIntegerField(default=0)
    fcm_token = models.CharField(max_length=500, blank=True, null=True)

    objects = UserManager()

    USERNAME_FIELD = 'firebase_uid'
    REQUIRED_FIELDS = ['email']

    def __str__(self):
        return self.name or self.email
