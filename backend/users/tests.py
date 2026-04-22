import uuid
import pytest
from rest_framework.test import APIClient
from users.models import User
from users.serializers import UserSerializer


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
def anon_client():
    return APIClient()


# ── Model ──────────────────────────────────────────────────────────────────────

@pytest.mark.django_db
def test_user_created(user):
    assert User.objects.filter(pk=user.pk).exists()


@pytest.mark.django_db
def test_user_str(user):
    assert str(user) == user.name


@pytest.mark.django_db
def test_user_defaults(user):
    assert user.rating == 5.00
    assert user.reviews_count == 0
    assert user.is_verified is False


# ── Serializer ─────────────────────────────────────────────────────────────────

@pytest.mark.django_db
def test_user_serializer_camel_case_keys(user):
    data = UserSerializer(user).data
    assert 'profileImageUrl' in data
    assert 'isVerified' in data
    assert 'joinDate' in data
    assert 'reviewsCount' in data
    assert 'profile_image' not in data
    assert 'is_verified' not in data
    assert 'join_date' not in data
    assert 'reviews_count' not in data


@pytest.mark.django_db
def test_user_serializer_no_password_field(user):
    assert 'password' not in UserSerializer(user).data


# ── Views ──────────────────────────────────────────────────────────────────────

@pytest.mark.django_db
def test_me_get(api_client, user):
    response = api_client.get('/api/v1/users/me/')
    assert response.status_code == 200
    assert response.data['id'] == str(user.id)
    assert response.data['name'] == user.name


@pytest.mark.django_db
def test_me_get_unauthenticated(anon_client):
    response = anon_client.get('/api/v1/users/me/')
    assert response.status_code == 403


@pytest.mark.django_db
def test_me_update(api_client):
    response = api_client.patch('/api/v1/users/me/', {'name': 'Alice Updated', 'bio': 'Hello!'})
    assert response.status_code == 200
    assert response.data['name'] == 'Alice Updated'
    assert response.data['bio'] == 'Hello!'


@pytest.mark.django_db
def test_me_update_partial(api_client):
    response = api_client.patch('/api/v1/users/me/', {'bio': 'Just bio'})
    assert response.status_code == 200
    assert response.data['bio'] == 'Just bio'


@pytest.mark.django_db
def test_user_detail(api_client, other_user):
    response = api_client.get(f'/api/v1/users/{other_user.id}/')
    assert response.status_code == 200
    assert response.data['id'] == str(other_user.id)


@pytest.mark.django_db
def test_user_detail_not_found(api_client):
    response = api_client.get(f'/api/v1/users/{uuid.uuid4()}/')
    assert response.status_code == 404


@pytest.mark.django_db
def test_user_search(api_client, user, other_user):
    response = api_client.get('/api/v1/users/search/?q=Bob')
    assert response.status_code == 200
    names = [u['name'] for u in response.data]
    assert 'Bob' in names


@pytest.mark.django_db
def test_user_search_no_q(api_client):
    response = api_client.get('/api/v1/users/search/')
    assert response.status_code == 400
