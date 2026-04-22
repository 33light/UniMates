import uuid
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='User',
            fields=[
                ('password', models.CharField(max_length=128, verbose_name='password')),
                ('last_login', models.DateTimeField(blank=True, null=True, verbose_name='last login')),
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('firebase_uid', models.CharField(max_length=128, unique=True)),
                ('name', models.CharField(max_length=255)),
                ('username', models.CharField(blank=True, max_length=100, null=True, unique=True)),
                ('email', models.EmailField(max_length=254, unique=True)),
                ('profile_image', models.ImageField(blank=True, null=True, upload_to='profiles/')),
                ('university', models.CharField(blank=True, max_length=255)),
                ('is_verified', models.BooleanField(default=False)),
                ('join_date', models.DateTimeField(auto_now_add=True)),
                ('bio', models.TextField(blank=True, null=True)),
                ('rating', models.DecimalField(decimal_places=2, default=5.0, max_digits=3)),
                ('reviews_count', models.PositiveIntegerField(default=0)),
                ('fcm_token', models.CharField(blank=True, max_length=500, null=True)),
            ],
            options={
                'abstract': False,
            },
        ),
    ]
