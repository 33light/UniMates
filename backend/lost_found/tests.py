import uuid
import pytest
from rest_framework.test import APIClient
from users.models import User
from lost_found.models import LostFoundItem
from lost_found.serializers import LostFoundItemSerializer


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


@pytest.fixture
def anon_client():
    return APIClient()


# ── Models ─────────────────────────────────────────────────────────────────────

@pytest.mark.django_db
def test_lost_found_item_created(user):
    item = LostFoundItem.objects.create(reporter=user, title='Blue Backpack', description='D', location='L', item_date='2025-02-28', type='lost')
    assert LostFoundItem.objects.filter(pk=item.pk).exists()


@pytest.mark.django_db
def test_lost_found_item_defaults(user):
    item = LostFoundItem.objects.create(reporter=user, title='T', description='D', location='L', item_date='2025-01-01', type='found')
    assert item.is_resolved is False
    assert item.image_urls == []
    assert item.resolved_by is None
    assert item.category is None


@pytest.mark.django_db
def test_lost_found_serializer_camel_case(user):
    item = LostFoundItem.objects.create(reporter=user, title='T', description='D', location='L', item_date='2025-01-01', type='lost')
    data = LostFoundItemSerializer(item, context={}).data
    for key in ['reporterId', 'reporterName', 'reporterImage', 'itemDate', 'imageUrls', 'isResolved', 'createdAt', 'resolvedBy']:
        assert key in data, f"Missing key: {key}"
    assert 'is_resolved' not in data
    assert 'item_date' not in data


# ── Views ──────────────────────────────────────────────────────────────────────

@pytest.mark.django_db
def test_item_list(api_client, user):
    LostFoundItem.objects.create(reporter=user, title='T1', description='D', location='L', item_date='2025-01-01', type='lost')
    LostFoundItem.objects.create(reporter=user, title='T2', description='D', location='L', item_date='2025-01-01', type='found')
    response = api_client.get('/api/v1/lost-found/')
    assert response.status_code == 200
    assert response.data['count'] == 2


@pytest.mark.django_db
def test_item_list_filter_by_type(api_client, user):
    LostFoundItem.objects.create(reporter=user, title='Lost Item', description='D', location='L', item_date='2025-01-01', type='lost')
    LostFoundItem.objects.create(reporter=user, title='Found Item', description='D', location='L', item_date='2025-01-01', type='found')
    response = api_client.get('/api/v1/lost-found/?type=lost')
    assert response.data['count'] == 1
    assert response.data['results'][0]['type'] == 'lost'


@pytest.mark.django_db
def test_item_list_filter_by_resolved(api_client, user):
    LostFoundItem.objects.create(reporter=user, title='Resolved', description='D', location='L', item_date='2025-01-01', type='lost', is_resolved=True)
    LostFoundItem.objects.create(reporter=user, title='Open', description='D', location='L', item_date='2025-01-01', type='lost', is_resolved=False)
    response = api_client.get('/api/v1/lost-found/?resolved=false')
    assert response.data['count'] == 1
    assert response.data['results'][0]['title'] == 'Open'


@pytest.mark.django_db
def test_item_list_unauthenticated(anon_client):
    response = anon_client.get('/api/v1/lost-found/')
    assert response.status_code == 403


@pytest.mark.django_db
def test_item_create(api_client):
    payload = {'title': 'Lost Keys', 'description': 'Left near canteen', 'location': 'Canteen', 'itemDate': '2025-03-01', 'type': 'lost'}
    response = api_client.post('/api/v1/lost-found/', payload, format='json')
    assert response.status_code == 201
    assert response.data['title'] == 'Lost Keys'
    assert response.data['isResolved'] is False


@pytest.mark.django_db
def test_item_create_missing_fields(api_client):
    response = api_client.post('/api/v1/lost-found/', {}, format='json')
    assert response.status_code == 400


@pytest.mark.django_db
def test_item_detail(api_client, user):
    item = LostFoundItem.objects.create(reporter=user, title='Detail Item', description='D', location='L', item_date='2025-01-01', type='lost')
    response = api_client.get(f'/api/v1/lost-found/{item.id}/')
    assert response.status_code == 200
    assert response.data['title'] == 'Detail Item'


@pytest.mark.django_db
def test_item_detail_not_found(api_client):
    response = api_client.get(f'/api/v1/lost-found/{uuid.uuid4()}/')
    assert response.status_code == 404


@pytest.mark.django_db
def test_item_update_owner(api_client, user):
    item = LostFoundItem.objects.create(reporter=user, title='Old Title', description='D', location='L', item_date='2025-01-01', type='lost')
    response = api_client.patch(f'/api/v1/lost-found/{item.id}/', {'title': 'Updated Title'}, format='json')
    assert response.status_code == 200
    assert response.data['title'] == 'Updated Title'


@pytest.mark.django_db
def test_item_update_non_owner(other_client, user):
    item = LostFoundItem.objects.create(reporter=user, title='T', description='D', location='L', item_date='2025-01-01', type='lost')
    response = other_client.patch(f'/api/v1/lost-found/{item.id}/', {'title': 'Hacked'}, format='json')
    assert response.status_code == 403


@pytest.mark.django_db
def test_item_delete_owner(api_client, user):
    item = LostFoundItem.objects.create(reporter=user, title='Delete Me', description='D', location='L', item_date='2025-01-01', type='lost')
    response = api_client.delete(f'/api/v1/lost-found/{item.id}/')
    assert response.status_code == 204
    assert not LostFoundItem.objects.filter(pk=item.id).exists()


@pytest.mark.django_db
def test_item_delete_non_owner(other_client, user):
    item = LostFoundItem.objects.create(reporter=user, title='T', description='D', location='L', item_date='2025-01-01', type='lost')
    response = other_client.delete(f'/api/v1/lost-found/{item.id}/')
    assert response.status_code == 403


@pytest.mark.django_db
def test_item_resolve(api_client, user, other_user):
    item = LostFoundItem.objects.create(reporter=user, title='T', description='D', location='L', item_date='2025-01-01', type='lost')
    response = api_client.post(f'/api/v1/lost-found/{item.id}/resolve/', {'resolvedById': str(other_user.id)}, format='json')
    assert response.status_code == 200
    assert response.data['isResolved'] is True
    assert response.data['resolvedBy'] == str(other_user.id)


@pytest.mark.django_db
def test_item_resolve_non_owner(other_client, user):
    item = LostFoundItem.objects.create(reporter=user, title='T', description='D', location='L', item_date='2025-01-01', type='lost')
    response = other_client.post(f'/api/v1/lost-found/{item.id}/resolve/', {}, format='json')
    assert response.status_code == 403
