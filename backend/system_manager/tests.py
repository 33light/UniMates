import uuid
import pytest
from rest_framework.test import APIClient
from users.models import User
from community.models import Post
from marketplace.models import MarketplaceItem
from lost_found.models import LostFoundItem


# ── Fixtures ───────────────────────────────────────────────────────────────────

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


# ── Global Search ──────────────────────────────────────────────────────────────

@pytest.mark.django_db
def test_search_returns_all_four_keys(api_client):
    response = api_client.get('/api/v1/search/?q=anything')
    assert response.status_code == 200
    assert 'posts' in response.data
    assert 'items' in response.data
    assert 'lostFound' in response.data
    assert 'users' in response.data


@pytest.mark.django_db
def test_search_finds_post(api_client, user):
    Post.objects.create(author=user, title='Django Tutorial', content='Learn Django')
    response = api_client.get('/api/v1/search/?q=django')
    assert response.status_code == 200
    titles = [p['title'] for p in response.data['posts']]
    assert 'Django Tutorial' in titles


@pytest.mark.django_db
def test_search_finds_marketplace_item(api_client, user):
    MarketplaceItem.objects.create(
        seller=user, title='Calculus Textbook', description='Good condition',
        category='Books', type='sell', price=500,
    )
    response = api_client.get('/api/v1/search/?q=calculus')
    assert response.status_code == 200
    titles = [i['title'] for i in response.data['items']]
    assert 'Calculus Textbook' in titles


@pytest.mark.django_db
def test_search_finds_lost_found_item(api_client, user):
    LostFoundItem.objects.create(
        reporter=user, title='Blue Umbrella', description='Found near main gate',
        location='Main Gate', item_date='2025-03-01', type='found',
    )
    response = api_client.get('/api/v1/search/?q=umbrella')
    assert response.status_code == 200
    titles = [i['title'] for i in response.data['lostFound']]
    assert 'Blue Umbrella' in titles


@pytest.mark.django_db
def test_search_finds_user(api_client, user, other_user):
    response = api_client.get('/api/v1/search/?q=Bob')
    assert response.status_code == 200
    names = [u['name'] for u in response.data['users']]
    assert 'Bob' in names


@pytest.mark.django_db
def test_search_empty_q_returns_400(api_client):
    response = api_client.get('/api/v1/search/')
    assert response.status_code == 400
    assert 'detail' in response.data


@pytest.mark.django_db
def test_search_no_match_returns_empty_lists(api_client):
    response = api_client.get('/api/v1/search/?q=zzznomatch999')
    assert response.status_code == 200
    assert response.data['posts'] == []
    assert response.data['items'] == []
    assert response.data['lostFound'] == []
    assert response.data['users'] == []


@pytest.mark.django_db
def test_search_unauthenticated(anon_client):
    response = anon_client.get('/api/v1/search/?q=test')
    assert response.status_code == 403


@pytest.mark.django_db
def test_search_case_insensitive(api_client, user):
    Post.objects.create(author=user, title='Python Programming', content='...')
    response = api_client.get('/api/v1/search/?q=PYTHON')
    assert response.status_code == 200
    titles = [p['title'] for p in response.data['posts']]
    assert 'Python Programming' in titles


@pytest.mark.django_db
def test_search_max_10_results_per_category(api_client, user):
    for i in range(15):
        Post.objects.create(author=user, title=f'Searchable Post {i}', content='...')
    response = api_client.get('/api/v1/search/?q=searchable')
    assert response.status_code == 200
    assert len(response.data['posts']) <= 10


@pytest.mark.django_db
def test_search_result_uses_correct_serializer_keys(api_client, user):
    Post.objects.create(author=user, title='Key Check Post', content='Content')
    response = api_client.get('/api/v1/search/?q=key check')
    assert response.status_code == 200
    if response.data['posts']:
        post = response.data['posts'][0]
        assert 'imageUrls' in post
        assert 'likesCount' in post
        assert 'createdAt' in post
        assert 'isLikedByCurrentUser' in post
