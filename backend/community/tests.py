import uuid
import pytest
from rest_framework.test import APIClient
from users.models import User
from community.models import Post, PostLike, Comment
from community.serializers import PostReadSerializer, CommentSerializer


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
def test_post_created(user):
    post = Post.objects.create(author=user, title='Hello', content='World')
    assert Post.objects.filter(pk=post.pk).exists()


@pytest.mark.django_db
def test_post_defaults(user):
    post = Post.objects.create(author=user, title='T', content='C')
    assert post.likes_count == 0
    assert post.comments_count == 0
    assert post.is_event is False
    assert post.image_urls == []


@pytest.mark.django_db
def test_postlike_signal_increments(user, other_user):
    post = Post.objects.create(author=user, title='T', content='C')
    PostLike.objects.create(post=post, user=other_user)
    post.refresh_from_db()
    assert post.likes_count == 1


@pytest.mark.django_db
def test_postlike_signal_decrements(user, other_user):
    post = Post.objects.create(author=user, title='T', content='C')
    like = PostLike.objects.create(post=post, user=other_user)
    post.refresh_from_db()
    like.delete()
    post.refresh_from_db()
    assert post.likes_count == 0


@pytest.mark.django_db
def test_comment_signal_increments(user, other_user):
    post = Post.objects.create(author=user, title='T', content='C')
    Comment.objects.create(post=post, author=other_user, content='Nice!')
    post.refresh_from_db()
    assert post.comments_count == 1


@pytest.mark.django_db
def test_postlike_unique_together(user):
    post = Post.objects.create(author=user, title='T', content='C')
    PostLike.objects.create(post=post, user=user)
    with pytest.raises(Exception):
        PostLike.objects.create(post=post, user=user)


# ── Serializers ────────────────────────────────────────────────────────────────

@pytest.mark.django_db
def test_post_serializer_camel_case(user):
    post = Post.objects.create(author=user, title='T', content='C')
    data = PostReadSerializer(post, context={}).data
    for key in ['imageUrls', 'likesCount', 'commentsCount', 'createdAt',
                'isLikedByCurrentUser', 'isEvent', 'eventDate', 'eventLocation']:
        assert key in data, f"Missing key: {key}"


@pytest.mark.django_db
def test_comment_serializer_camel_case(user):
    post = Post.objects.create(author=user, title='T', content='C')
    comment = Comment.objects.create(post=post, author=user, content='Hi')
    data = CommentSerializer(comment, context={}).data
    assert 'postId' in data
    assert 'createdAt' in data
    assert 'author' in data


# ── Views ──────────────────────────────────────────────────────────────────────

@pytest.mark.django_db
def test_post_list(api_client, user):
    Post.objects.create(author=user, title='Post 1', content='...')
    Post.objects.create(author=user, title='Post 2', content='...')
    response = api_client.get('/api/v1/community/posts/')
    assert response.status_code == 200
    assert response.data['count'] == 2


@pytest.mark.django_db
def test_post_list_pagination(api_client, user):
    for i in range(15):
        Post.objects.create(author=user, title=f'Post {i}', content='...')
    response = api_client.get('/api/v1/community/posts/?page=0&page_size=10')
    assert response.status_code == 200
    assert len(response.data['results']) == 10
    assert response.data['count'] == 15


@pytest.mark.django_db
def test_post_create(api_client):
    payload = {'title': 'New Post', 'content': 'Some content', 'isEvent': False}
    response = api_client.post('/api/v1/community/posts/', payload, format='json')
    assert response.status_code == 201
    assert response.data['title'] == 'New Post'


@pytest.mark.django_db
def test_post_create_missing_fields(api_client):
    response = api_client.post('/api/v1/community/posts/', {}, format='json')
    assert response.status_code == 400


@pytest.mark.django_db
def test_post_detail(api_client, user):
    post = Post.objects.create(author=user, title='Detail Post', content='...')
    response = api_client.get(f'/api/v1/community/posts/{post.id}/')
    assert response.status_code == 200
    assert response.data['title'] == 'Detail Post'


@pytest.mark.django_db
def test_post_detail_not_found(api_client):
    response = api_client.get(f'/api/v1/community/posts/{uuid.uuid4()}/')
    assert response.status_code == 404


@pytest.mark.django_db
def test_post_delete_owner(api_client, user):
    post = Post.objects.create(author=user, title='To delete', content='...')
    response = api_client.delete(f'/api/v1/community/posts/{post.id}/')
    assert response.status_code == 204
    assert not Post.objects.filter(pk=post.id).exists()


@pytest.mark.django_db
def test_post_delete_non_owner(other_client, user):
    post = Post.objects.create(author=user, title='Protected', content='...')
    response = other_client.delete(f'/api/v1/community/posts/{post.id}/')
    assert response.status_code == 403


@pytest.mark.django_db
def test_post_like_toggle_like(api_client, user):
    post = Post.objects.create(author=user, title='T', content='C')
    response = api_client.post(f'/api/v1/community/posts/{post.id}/like/')
    assert response.status_code == 200
    assert response.data['liked'] is True
    assert response.data['likesCount'] == 1


@pytest.mark.django_db
def test_post_like_toggle_unlike(api_client, user):
    post = Post.objects.create(author=user, title='T', content='C')
    api_client.post(f'/api/v1/community/posts/{post.id}/like/')
    response = api_client.post(f'/api/v1/community/posts/{post.id}/like/')
    assert response.data['liked'] is False
    assert response.data['likesCount'] == 0


@pytest.mark.django_db
def test_is_liked_by_current_user_false(api_client, user):
    post = Post.objects.create(author=user, title='T', content='C')
    response = api_client.get(f'/api/v1/community/posts/{post.id}/')
    assert response.data['isLikedByCurrentUser'] is False


@pytest.mark.django_db
def test_is_liked_by_current_user_true(api_client, user):
    post = Post.objects.create(author=user, title='T', content='C')
    PostLike.objects.create(post=post, user=user)
    response = api_client.get(f'/api/v1/community/posts/{post.id}/')
    assert response.data['isLikedByCurrentUser'] is True


@pytest.mark.django_db
def test_comment_list(api_client, user):
    post = Post.objects.create(author=user, title='T', content='C')
    Comment.objects.create(post=post, author=user, content='First')
    Comment.objects.create(post=post, author=user, content='Second')
    response = api_client.get(f'/api/v1/community/posts/{post.id}/comments/')
    assert response.status_code == 200
    assert len(response.data) == 2


@pytest.mark.django_db
def test_comment_create(api_client, user):
    post = Post.objects.create(author=user, title='T', content='C')
    response = api_client.post(
        f'/api/v1/community/posts/{post.id}/comments/',
        {'content': 'Great post!'},
        format='json'
    )
    assert response.status_code == 201
    assert response.data['content'] == 'Great post!'
    post.refresh_from_db()
    assert post.comments_count == 1


@pytest.mark.django_db
def test_comment_create_on_missing_post(api_client):
    response = api_client.post(
        f'/api/v1/community/posts/{uuid.uuid4()}/comments/',
        {'content': 'Hello'},
        format='json'
    )
    assert response.status_code == 404
