import uuid
import pytest
from rest_framework.test import APIClient
from users.models import User
from messaging.models import Conversation, Message
from messaging.serializers import ConversationSerializer, MessageSerializer


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
def test_conversation_created(user, other_user):
    conv = Conversation.objects.create(user1=user, user2=other_user)
    assert Conversation.objects.filter(pk=conv.pk).exists()


@pytest.mark.django_db
def test_conversation_unique_together(user, other_user):
    Conversation.objects.create(user1=user, user2=other_user)
    with pytest.raises(Exception):
        Conversation.objects.create(user1=user, user2=other_user)


@pytest.mark.django_db
def test_message_signal_updates_conversation(user, other_user):
    conv = Conversation.objects.create(user1=user, user2=other_user)
    Message.objects.create(conversation=conv, sender=user, content='Hello there')
    conv.refresh_from_db()
    assert conv.last_message == 'Hello there'


# ── Serializers ────────────────────────────────────────────────────────────────

@pytest.mark.django_db
def test_conversation_serializer_camel_case(user, other_user):
    conv = Conversation.objects.create(user1=user, user2=other_user)
    data = ConversationSerializer(conv, context={}).data
    for key in ['userId1', 'userId2', 'user1Name', 'user2Name',
                'user1Image', 'user2Image', 'lastMessage', 'lastMessageTime', 'unreadCount']:
        assert key in data, f"Missing key: {key}"


@pytest.mark.django_db
def test_message_serializer_camel_case(user, other_user):
    conv = Conversation.objects.create(user1=user, user2=other_user)
    msg = Message.objects.create(conversation=conv, sender=user, content='Hi')
    data = MessageSerializer(msg, context={}).data
    for key in ['conversationId', 'senderId', 'senderName', 'senderImage', 'imageUrls', 'isRead']:
        assert key in data, f"Missing key: {key}"


# ── Views ──────────────────────────────────────────────────────────────────────

@pytest.mark.django_db
def test_conversation_list(api_client, user, other_user):
    Conversation.objects.create(user1=user, user2=other_user)
    response = api_client.get('/api/v1/messaging/conversations/')
    assert response.status_code == 200
    assert len(response.data) == 1


@pytest.mark.django_db
def test_conversation_create_new(api_client, user, other_user):
    response = api_client.post(
        '/api/v1/messaging/conversations/',
        {'otherUserId': str(other_user.id)},
        format='json'
    )
    assert response.status_code == 201
    assert Conversation.objects.count() == 1


@pytest.mark.django_db
def test_conversation_create_existing(api_client, user, other_user):
    api_client.post('/api/v1/messaging/conversations/', {'otherUserId': str(other_user.id)}, format='json')
    response = api_client.post('/api/v1/messaging/conversations/', {'otherUserId': str(other_user.id)}, format='json')
    assert response.status_code == 200
    assert Conversation.objects.count() == 1


@pytest.mark.django_db
def test_conversation_create_missing_other_user_id(api_client):
    response = api_client.post('/api/v1/messaging/conversations/', {}, format='json')
    assert response.status_code == 400


@pytest.mark.django_db
def test_message_list(api_client, user, other_user):
    conv = Conversation.objects.create(user1=user, user2=other_user)
    Message.objects.create(conversation=conv, sender=user, content='Hi')
    Message.objects.create(conversation=conv, sender=other_user, content='Hey')
    response = api_client.get(f'/api/v1/messaging/conversations/{conv.id}/messages/')
    assert response.status_code == 200
    assert len(response.data) == 2


@pytest.mark.django_db
def test_message_list_forbidden_for_non_participant(other_client, user):
    third = make_user(name='Third', username='third_user')
    conv = Conversation.objects.create(user1=user, user2=third)
    response = other_client.get(f'/api/v1/messaging/conversations/{conv.id}/messages/')
    assert response.status_code == 403


@pytest.mark.django_db
def test_message_create(api_client, user, other_user):
    conv = Conversation.objects.create(user1=user, user2=other_user)
    response = api_client.post(
        f'/api/v1/messaging/conversations/{conv.id}/messages/',
        {'content': 'Hello!'},
        format='json'
    )
    assert response.status_code == 201
    assert response.data['content'] == 'Hello!'
    conv.refresh_from_db()
    assert conv.last_message == 'Hello!'


@pytest.mark.django_db
def test_mark_read(api_client, user, other_user):
    conv = Conversation.objects.create(user1=user, user2=other_user)
    Message.objects.create(conversation=conv, sender=other_user, content='Msg1')
    Message.objects.create(conversation=conv, sender=other_user, content='Msg2')
    response = api_client.post(f'/api/v1/messaging/conversations/{conv.id}/mark_read/')
    assert response.status_code == 200
    assert conv.messages.filter(is_read=False).exclude(sender=user).count() == 0


@pytest.mark.django_db
def test_unread_count_in_conversation(api_client, user, other_user):
    conv = Conversation.objects.create(user1=user, user2=other_user)
    Message.objects.create(conversation=conv, sender=other_user, content='Unread 1')
    Message.objects.create(conversation=conv, sender=other_user, content='Unread 2')
    response = api_client.get('/api/v1/messaging/conversations/')
    assert response.data[0]['unreadCount'] == 2
