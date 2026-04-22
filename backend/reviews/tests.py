import uuid
import pytest
from rest_framework.test import APIClient
from users.models import User
from reviews.models import Review
from reviews.serializers import ReviewSerializer


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


# ── Models & Signal ────────────────────────────────────────────────────────────

@pytest.mark.django_db
def test_review_created(user, other_user):
    review = Review.objects.create(reviewer=user, target_user=other_user, rating=4.5, comment='Great!')
    assert Review.objects.filter(pk=review.pk).exists()


@pytest.mark.django_db
def test_review_unique_together(user, other_user):
    Review.objects.create(reviewer=user, target_user=other_user, rating=4.0, comment='Good')
    with pytest.raises(Exception):
        Review.objects.create(reviewer=user, target_user=other_user, rating=3.0, comment='Dup')


@pytest.mark.django_db
def test_signal_updates_rating(user, other_user):
    third = make_user(name='Third', username='third_sig')
    Review.objects.create(reviewer=user, target_user=other_user, rating=4.0, comment='A')
    Review.objects.create(reviewer=third, target_user=other_user, rating=2.0, comment='B')
    other_user.refresh_from_db()
    assert float(other_user.rating) == pytest.approx(3.0, abs=0.01)
    assert other_user.reviews_count == 2


# ── Serializer ─────────────────────────────────────────────────────────────────

@pytest.mark.django_db
def test_review_serializer_camel_case(user, other_user):
    review = Review.objects.create(reviewer=user, target_user=other_user, rating=4.5, comment='Great')
    data = ReviewSerializer(review, context={}).data
    for key in ['reviewerId', 'reviewerName', 'reviewerImage', 'targetUserId', 'createdAt']:
        assert key in data, f"Missing key: {key}"
    assert 'created_at' not in data
    assert 'target_user' not in data


# ── Views ──────────────────────────────────────────────────────────────────────

@pytest.mark.django_db
def test_review_list(api_client, user, other_user):
    Review.objects.create(reviewer=user, target_user=other_user, rating=4.0, comment='Good')
    response = api_client.get(f'/api/v1/reviews/?target_user_id={other_user.id}')
    assert response.status_code == 200
    assert len(response.data) == 1
    assert response.data[0]['reviewerName'] == user.name


@pytest.mark.django_db
def test_review_list_missing_target_user_id(api_client):
    response = api_client.get('/api/v1/reviews/')
    assert response.status_code == 400


@pytest.mark.django_db
def test_review_list_unauthenticated(anon_client, other_user):
    response = anon_client.get(f'/api/v1/reviews/?target_user_id={other_user.id}')
    assert response.status_code == 403


@pytest.mark.django_db
def test_review_create_success(api_client, user, other_user):
    payload = {'targetUserId': str(other_user.id), 'rating': 4.5, 'comment': 'Very helpful!'}
    response = api_client.post('/api/v1/reviews/', payload, format='json')
    assert response.status_code == 201
    assert float(response.data['rating']) == pytest.approx(4.5, abs=0.01)
    assert response.data['targetUserId'] == str(other_user.id)


@pytest.mark.django_db
def test_review_create_updates_target_rating(api_client, user, other_user):
    api_client.post('/api/v1/reviews/', {'targetUserId': str(other_user.id), 'rating': 3.0, 'comment': 'OK'}, format='json')
    other_user.refresh_from_db()
    assert float(other_user.rating) == pytest.approx(3.0, abs=0.01)
    assert other_user.reviews_count == 1


@pytest.mark.django_db
def test_review_create_duplicate_returns_400(api_client, user, other_user):
    api_client.post('/api/v1/reviews/', {'targetUserId': str(other_user.id), 'rating': 4.0, 'comment': 'First'}, format='json')
    response = api_client.post('/api/v1/reviews/', {'targetUserId': str(other_user.id), 'rating': 5.0, 'comment': 'Second'}, format='json')
    assert response.status_code == 400
    assert 'already reviewed' in response.data['detail'].lower()


@pytest.mark.django_db
def test_review_create_self_review_returns_400(api_client, user):
    response = api_client.post('/api/v1/reviews/', {'targetUserId': str(user.id), 'rating': 5.0, 'comment': 'Self'}, format='json')
    assert response.status_code == 400
    assert 'yourself' in response.data['detail'].lower()


@pytest.mark.django_db
def test_review_create_target_not_found(api_client):
    response = api_client.post('/api/v1/reviews/', {'targetUserId': str(uuid.uuid4()), 'rating': 4.0, 'comment': 'Ghost'}, format='json')
    assert response.status_code == 404


@pytest.mark.django_db
def test_has_reviewed_false(api_client, other_user):
    response = api_client.get(f'/api/v1/reviews/has_reviewed/?target_user_id={other_user.id}')
    assert response.status_code == 200
    assert response.data['hasReviewed'] is False


@pytest.mark.django_db
def test_has_reviewed_true(api_client, user, other_user):
    Review.objects.create(reviewer=user, target_user=other_user, rating=4.0, comment='Good')
    response = api_client.get(f'/api/v1/reviews/has_reviewed/?target_user_id={other_user.id}')
    assert response.status_code == 200
    assert response.data['hasReviewed'] is True


@pytest.mark.django_db
def test_has_reviewed_missing_param(api_client):
    response = api_client.get('/api/v1/reviews/has_reviewed/')
    assert response.status_code == 400
