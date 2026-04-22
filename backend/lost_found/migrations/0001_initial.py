import uuid
from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='LostFoundItem',
            fields=[
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('title', models.CharField(max_length=300)),
                ('description', models.TextField()),
                ('location', models.CharField(max_length=300)),
                ('category', models.CharField(blank=True, max_length=100, null=True)),
                ('item_date', models.DateField()),
                ('image_urls', models.JSONField(default=list)),
                ('type', models.CharField(choices=[('lost', 'Lost'), ('found', 'Found')], max_length=5)),
                ('is_resolved', models.BooleanField(default=False)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('reporter', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='lost_found_reports', to=settings.AUTH_USER_MODEL)),
                ('resolved_by', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='resolved_items', to=settings.AUTH_USER_MODEL)),
            ],
        ),
    ]
