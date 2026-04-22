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
            name='MarketplaceItem',
            fields=[
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('title', models.CharField(max_length=300)),
                ('description', models.TextField()),
                ('image_urls', models.JSONField(default=list)),
                ('category', models.CharField(max_length=100)),
                ('condition', models.CharField(blank=True, max_length=50, null=True)),
                ('type', models.CharField(choices=[('buy', 'Buy'), ('sell', 'Sell'), ('borrow', 'Borrow'), ('exchange', 'Exchange')], default='sell', max_length=10)),
                ('price', models.DecimalField(blank=True, decimal_places=2, max_digits=10, null=True)),
                ('exchange_terms', models.TextField(blank=True, null=True)),
                ('is_sold', models.BooleanField(default=False)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('rating', models.DecimalField(decimal_places=2, default=5.0, max_digits=3)),
                ('reviews_count', models.PositiveIntegerField(default=0)),
                ('seller', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='listings', to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.CreateModel(
            name='Wishlist',
            fields=[
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('added_at', models.DateTimeField(auto_now_add=True)),
                ('marketplace_item', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='marketplace.marketplaceitem')),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='wishlist', to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'unique_together': {('user', 'marketplace_item')},
            },
        ),
    ]
