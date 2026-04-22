import uuid
import pytest
from rest_framework.test import APIClient
from users.models import User
from marketplace.models import MarketplaceItem, Wishlist
from marketplace.serializers import MarketplaceItemSerializer


def make_user(**kwargs):
    uid = str(uuid.uuid4())
    defaults = dict(firebase_uid=uid, email=f"{uid[:8]}@test.com", name="Test User", username=uid[:8])
    defaults.update(kwargs)
    user = User(**defaults)
    user.set_unusable_password()
    user.save()
    return user


@pytest.fixture
def user(db):
    return make_user(name="Alice", username="alice")


@pytest.fixture
def other_user(db):
    return make_user(name="Bob", username="bob")


@pytest.fixture
def api_client(user):
    client = APIClient()
    client.force_authenticate(user=user)
    return client


@pytest.fixture
def other_client(other_user):
    client = APIClient()
    client.force_authenticate(user=other_user)
    return client


# ── Models ─────────────────────────────────────────────────────────────────────

@pytest.mark.django_db
def test_marketplace_item_created(user):
    item = MarketplaceItem.objects.create(seller=user, title='Book', description='D', category='Books', type='sell', price=500)
    assert MarketplaceItem.objects.filter(pk=item.pk).exists()


@pytest.mark.django_db
def test_marketplace_item_defaults(user):
    item = MarketplaceItem.objects.create(seller=user, title='T', description='D', category='Other', type='sell')
    assert item.is_sold is False
    assert item.image_urls == []
    assert item.rating == 5.00


@pytest.mark.django_db
def test_wishlist_unique_together(user):
    item = MarketplaceItem.objects.create(seller=user, title='T', description='D', category='C', type='sell')
    Wishlist.objects.create(user=user, marketplace_item=item)
    with pytest.raises(Exception):
        Wishlist.objects.create(user=user, marketplace_item=item)


# ── Serializer ─────────────────────────────────────────────────────────────────

@pytest.mark.django_db
def test_marketplace_serializer_camel_case(user):
    item = MarketplaceItem.objects.create(seller=user, title='T', description='D', category='C', type='sell', price=100)
    data = MarketplaceItemSerializer(item, context={}).data
    for key in ['userId', 'sellerName', 'sellerImage', 'imageUrls', 'exchangeTerms', 'isSold', 'createdAt', 'reviewsCount']:
        assert key in data, f"Missing key: {key}"
    assert data['userId'] == str(user.id)
    assert data['sellerName'] == user.name


# ── Views ──────────────────────────────────────────────────────────────────────

@pytest.mark.django_db
def test_item_list(api_client, user):
    MarketplaceItem.objects.create(seller=user, title='Book', description='D', category='Books', type='sell')
    response = api_client.get('/api/v1/marketplace/items/')
    assert response.status_code == 200
    assert response.data['count'] == 1


@pytest.mark.django_db
def test_item_list_filter_by_type(api_client, user):
    MarketplaceItem.objects.create(seller=user, title='Sell', description='D', category='C', type='sell')
    MarketplaceItem.objects.create(seller=user, title='Borrow', description='D', category='C', type='borrow')
    response = api_client.get('/api/v1/marketplace/items/?type=sell')
    assert response.data['count'] == 1
    assert response.data['results'][0]['title'] == 'Sell'


@pytest.mark.django_db
def test_item_list_filter_by_price(api_client, user):
    MarketplaceItem.objects.create(seller=user, title='Cheap', description='D', category='C', type='sell', price=100)
    MarketplaceItem.objects.create(seller=user, title='Expensive', description='D', category='C', type='sell', price=900)
    response = api_client.get('/api/v1/marketplace/items/?max_price=500')
    assert response.data['count'] == 1


@pytest.mark.django_db
def test_item_create(api_client):
    payload = {'title': 'New Item', 'description': 'Desc', 'category': 'Books', 'type': 'sell', 'price': 200}
    response = api_client.post('/api/v1/marketplace/items/', payload, format='json')
    assert response.status_code == 201
    assert response.data['title'] == 'New Item'


@pytest.mark.django_db
def test_item_detail(api_client, user):
    item = MarketplaceItem.objects.create(seller=user, title='Detail Item', description='D', category='C', type='sell')
    response = api_client.get(f'/api/v1/marketplace/items/{item.id}/')
    assert response.status_code == 200
    assert response.data['title'] == 'Detail Item'


@pytest.mark.django_db
def test_item_update_owner(api_client, user):
    item = MarketplaceItem.objects.create(seller=user, title='Old Title', description='D', category='C', type='sell')
    response = api_client.patch(f'/api/v1/marketplace/items/{item.id}/', {'title': 'New Title'}, format='json')
    assert response.status_code == 200
    assert response.data['title'] == 'New Title'


@pytest.mark.django_db
def test_item_update_non_owner(other_client, user):
    item = MarketplaceItem.objects.create(seller=user, title='T', description='D', category='C', type='sell')
    response = other_client.patch(f'/api/v1/marketplace/items/{item.id}/', {'title': 'Hacked'}, format='json')
    assert response.status_code == 403


@pytest.mark.django_db
def test_item_delete_owner(api_client, user):
    item = MarketplaceItem.objects.create(seller=user, title='Delete Me', description='D', category='C', type='sell')
    response = api_client.delete(f'/api/v1/marketplace/items/{item.id}/')
    assert response.status_code == 204
    assert not MarketplaceItem.objects.filter(pk=item.id).exists()


@pytest.mark.django_db
def test_item_delete_non_owner(other_client, user):
    item = MarketplaceItem.objects.create(seller=user, title='T', description='D', category='C', type='sell')
    response = other_client.delete(f'/api/v1/marketplace/items/{item.id}/')
    assert response.status_code == 403


@pytest.mark.django_db
def test_mark_sold(api_client, user):
    item = MarketplaceItem.objects.create(seller=user, title='T', description='D', category='C', type='sell')
    response = api_client.post(f'/api/v1/marketplace/items/{item.id}/mark_sold/')
    assert response.status_code == 200
    assert response.data['isSold'] is True


@pytest.mark.django_db
def test_my_items(api_client, user, other_user):
    MarketplaceItem.objects.create(seller=user, title='Mine', description='D', category='C', type='sell')
    MarketplaceItem.objects.create(seller=other_user, title='Not Mine', description='D', category='C', type='sell')
    response = api_client.get('/api/v1/marketplace/items/my/')
    assert response.data['count'] == 1
    assert response.data['results'][0]['title'] == 'Mine'


@pytest.mark.django_db
def test_wishlist_toggle_add(api_client, user):
    item = MarketplaceItem.objects.create(seller=user, title='T', description='D', category='C', type='sell')
    response = api_client.post(f'/api/v1/marketplace/wishlist/{item.id}/toggle/')
    assert response.status_code == 200
    assert response.data['wishlisted'] is True
    assert Wishlist.objects.filter(user=user, marketplace_item=item).exists()


@pytest.mark.django_db
def test_wishlist_toggle_remove(api_client, user):
    item = MarketplaceItem.objects.create(seller=user, title='T', description='D', category='C', type='sell')
    api_client.post(f'/api/v1/marketplace/wishlist/{item.id}/toggle/')
    response = api_client.post(f'/api/v1/marketplace/wishlist/{item.id}/toggle/')
    assert response.data['wishlisted'] is False
    assert not Wishlist.objects.filter(user=user, marketplace_item=item).exists()


@pytest.mark.django_db
def test_wishlist_list(api_client, user):
    item = MarketplaceItem.objects.create(seller=user, title='Wishlisted', description='D', category='C', type='sell')
    Wishlist.objects.create(user=user, marketplace_item=item)
    response = api_client.get('/api/v1/marketplace/wishlist/')
    assert response.status_code == 200
    assert len(response.data) == 1
    assert response.data[0]['title'] == 'Wishlisted'
