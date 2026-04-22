# UniMates — Django Backend Implementation Guide

This document is the **single source of truth** for building the Django REST API backend for the UniMates Flutter app.
It is written so that an AI assistant working in the backend repository (with no access to the Flutter codebase) can understand the full data contract and implement every endpoint correctly.

---

## 1. Project Context

UniMates is a student community platform with 6 modules:

| Module | Status in Flutter |
|---|---|
| Auth | Firebase Auth (email/password + Google Sign-In) |
| Community | Posts, comments, likes |
| Marketplace | Listings (sell/buy/borrow/exchange), wishlist |
| Messaging | 1-on-1 conversations + messages |
| Lost & Found | Report lost/found items, resolve |
| Reviews | User-to-user ratings (after marketplace or lost&found interaction) |

The Flutter app currently reads from local JSON files via `MockApiService`.
The backend must expose a REST API that **exactly replaces** every method in `MockApiService`,
keeping the same JSON field names the Flutter models already expect.

### Authentication model
- Firebase handles sign-up and login on the client.
- Every authenticated request from Flutter sends an **`Authorization: Bearer <firebase_id_token>`** header.
- The Django backend must **verify** that token against Firebase using the `firebase-admin` SDK, then map the Firebase UID to a Django user row.
- The backend does **not** manage passwords.

---

## 2. Recommended Tech Stack

```
Django 5.x
djangorestframework (DRF) 3.15+
djangorestframework-simplejwt  ← NOT used for auth; Firebase does auth
firebase-admin                 ← token verification
django-cors-headers            ← Flutter will call from any origin
Pillow                         ← image handling
django-storages + boto3        ← S3 or any object storage for images
psycopg2-binary                ← PostgreSQL (recommended)
django-filter                  ← filtering on list endpoints
channels + daphne              ← WebSockets for real-time messaging (Phase 4)
```

---

## 3. Project Structure

```
unimates_backend/
├── manage.py
├── config/
│   ├── settings/
│   │   ├── base.py
│   │   ├── development.py
│   │   └── production.py
│   ├── urls.py
│   └── wsgi.py
├── apps/
│   ├── users/          # UniMatesUser, Firebase auth middleware
│   ├── community/      # Post, Comment, PostLike
│   ├── marketplace/    # MarketplaceItem, Wishlist
│   ├── messaging/      # Conversation, Message
│   ├── lost_found/     # LostFoundItem
│   └── reviews/        # Review
├── common/
│   ├── authentication.py   # Firebase token verifier
│   ├── permissions.py
│   └── pagination.py
└── requirements.txt
```

---

## 4. Firebase Authentication Middleware

Every view must be protected by a custom DRF authentication class that:

1. Reads `Authorization: Bearer <token>` from the request header.
2. Calls `firebase_admin.auth.verify_id_token(token)`.
3. Extracts `uid` and `email` from the decoded token.
4. Gets or creates a `User` row using `firebase_uid` as the lookup key.
5. Sets `request.user` to that `User` instance.

```python
# common/authentication.py
import firebase_admin
from firebase_admin import auth as firebase_auth
from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed
from apps.users.models import User

class FirebaseAuthentication(BaseAuthentication):
    def authenticate(self, request):
        auth_header = request.headers.get('Authorization', '')
        if not auth_header.startswith('Bearer '):
            return None
        token = auth_header.split(' ', 1)[1]
        try:
            decoded = firebase_auth.verify_id_token(token)
        except Exception:
            raise AuthenticationFailed('Invalid Firebase token')
        uid = decoded['uid']
        email = decoded.get('email', '')
        name = decoded.get('name', '')
        user, _ = User.objects.get_or_create(
            firebase_uid=uid,
            defaults={'email': email, 'name': name},
        )
        return (user, None)
```

Set this as the default authentication class in `settings/base.py`:
```python
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'common.authentication.FirebaseAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    'DEFAULT_PAGINATION_CLASS': 'common.pagination.PageNumberPagination',
    'PAGE_SIZE': 10,
}
```

---

## 5. Data Models

All field names below are **the exact JSON keys** the Flutter app uses. Do not rename them.

### 5.1 User (`apps/users/models.py`)

```python
class User(AbstractBaseUser):
    firebase_uid   = CharField(max_length=128, unique=True)
    id             = UUIDField(primary_key=True, default=uuid4)
    name           = CharField(max_length=255)
    username       = CharField(max_length=100, unique=True)
    email          = EmailField(unique=True)
    profile_image  = ImageField(upload_to='profiles/', null=True, blank=True)
    university     = CharField(max_length=255, blank=True)
    is_verified    = BooleanField(default=False)
    join_date      = DateTimeField(auto_now_add=True)
    bio            = TextField(blank=True, null=True)

    # Computed / denormalised — update on review save
    rating         = DecimalField(max_digits=3, decimal_places=2, default=5.00)
    reviews_count  = PositiveIntegerField(default=0)

    USERNAME_FIELD = 'firebase_uid'
```

**Serializer JSON output** (matches `UniMatesUser.fromJson`):
```json
{
  "id": "uuid-string",
  "name": "Alice Smith",
  "username": "alice_smith",
  "email": "alice@uni.edu",
  "profileImageUrl": "https://cdn.../profiles/alice.jpg",
  "university": "IBA Karachi",
  "isVerified": false,
  "joinDate": "2025-01-15T00:00:00.000Z",
  "bio": "CS student",
  "rating": 4.8,
  "reviewsCount": 12
}
```

> **Key mapping** — Django snake_case → Flutter camelCase:
> `profile_image` → `profileImageUrl`, `is_verified` → `isVerified`, `join_date` → `joinDate`, `reviews_count` → `reviewsCount`
>
> All serializers must use `source` or `SerializerMethodField` to emit the camelCase keys Flutter expects.

---

### 5.2 Post (`apps/community/models.py`)

```python
class Post(Model):
    id             = UUIDField(primary_key=True, default=uuid4)
    author         = ForeignKey(User, on_delete=CASCADE, related_name='posts')
    title          = CharField(max_length=300)
    content        = TextField()
    image_urls     = JSONField(default=list)   # list of URL strings
    is_event       = BooleanField(default=False)
    event_date     = DateTimeField(null=True, blank=True)
    event_location = CharField(max_length=300, null=True, blank=True)
    created_at     = DateTimeField(auto_now_add=True)

    # Denormalised counters (update via signals)
    likes_count    = PositiveIntegerField(default=0)
    comments_count = PositiveIntegerField(default=0)


class PostLike(Model):
    post    = ForeignKey(Post, on_delete=CASCADE, related_name='likes')
    user    = ForeignKey(User, on_delete=CASCADE)
    created = DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = [('post', 'user')]
```

**Serializer JSON output** (matches `Post.fromJson`):
```json
{
  "id": "uuid",
  "title": "Study group for DBMS",
  "content": "Anyone interested?",
  "author": { ...UserObject },
  "imageUrls": [],
  "likesCount": 3,
  "commentsCount": 2,
  "createdAt": "2025-02-01T10:00:00.000Z",
  "isLikedByCurrentUser": false,
  "isEvent": false,
  "eventDate": null,
  "eventLocation": null
}
```

> `isLikedByCurrentUser` must be a `SerializerMethodField` that checks if `request.user` has a `PostLike` for this post.

---

### 5.3 Comment (`apps/community/models.py`)

```python
class Comment(Model):
    id         = UUIDField(primary_key=True, default=uuid4)
    post       = ForeignKey(Post, on_delete=CASCADE, related_name='comments_set')
    author     = ForeignKey(User, on_delete=CASCADE)
    content    = TextField()
    created_at = DateTimeField(auto_now_add=True)
```

**Serializer JSON output** (matches `Comment.fromJson`):
```json
{
  "id": "uuid",
  "postId": "uuid",
  "author": { ...UserObject },
  "content": "Great idea!",
  "createdAt": "2025-02-01T11:00:00.000Z"
}
```

---

### 5.4 MarketplaceItem (`apps/marketplace/models.py`)

```python
class ListingType(TextChoices):
    BUY      = 'buy'
    SELL     = 'sell'
    BORROW   = 'borrow'
    EXCHANGE = 'exchange'

class MarketplaceItem(Model):
    id             = UUIDField(primary_key=True, default=uuid4)
    seller         = ForeignKey(User, on_delete=CASCADE, related_name='listings')
    title          = CharField(max_length=300)
    description    = TextField()
    image_urls     = JSONField(default=list)
    category       = CharField(max_length=100)
    condition      = CharField(max_length=50, null=True, blank=True)
    type           = CharField(max_length=10, choices=ListingType.choices, default=ListingType.SELL)
    price          = DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    exchange_terms = TextField(null=True, blank=True)
    is_sold        = BooleanField(default=False)
    created_at     = DateTimeField(auto_now_add=True)

    # Denormalised
    rating         = DecimalField(max_digits=3, decimal_places=2, default=5.00)
    reviews_count  = PositiveIntegerField(default=0)
```

**Serializer JSON output** (matches `MarketplaceItem.fromJson`):
```json
{
  "id": "uuid",
  "userId": "seller-uuid",
  "sellerName": "Alice Smith",
  "sellerImage": "https://...",
  "title": "Calculus Textbook",
  "description": "Good condition",
  "imageUrls": [],
  "category": "Books",
  "condition": "Good",
  "type": "sell",
  "price": 500.00,
  "exchangeTerms": null,
  "createdAt": "2025-03-01T08:00:00.000Z",
  "isSold": false,
  "rating": 5.0,
  "reviewsCount": 0
}
```

> `userId` = `seller.id`, `sellerName` = `seller.name`, `sellerImage` = `seller.profileImageUrl` — all derived via `SerializerMethodField`.

---

### 5.5 Wishlist (`apps/marketplace/models.py`)

```python
class Wishlist(Model):
    id                  = UUIDField(primary_key=True, default=uuid4)
    user                = ForeignKey(User, on_delete=CASCADE, related_name='wishlist')
    marketplace_item    = ForeignKey(MarketplaceItem, on_delete=CASCADE)
    added_at            = DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = [('user', 'marketplace_item')]
```

---

### 5.6 Conversation & Message (`apps/messaging/models.py`)

```python
class Conversation(Model):
    id                 = UUIDField(primary_key=True, default=uuid4)
    user1              = ForeignKey(User, on_delete=CASCADE, related_name='conv_as_user1')
    user2              = ForeignKey(User, on_delete=CASCADE, related_name='conv_as_user2')
    last_message       = TextField(blank=True)
    last_message_time  = DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = [('user1', 'user2')]

class Message(Model):
    id              = UUIDField(primary_key=True, default=uuid4)
    conversation    = ForeignKey(Conversation, on_delete=CASCADE, related_name='messages')
    sender          = ForeignKey(User, on_delete=CASCADE)
    content         = TextField()
    image_urls      = JSONField(default=list)
    timestamp       = DateTimeField(auto_now_add=True)
    is_read         = BooleanField(default=False)
```

**Conversation JSON output** (matches `Conversation.fromJson`):
```json
{
  "id": "uuid",
  "userId1": "uuid",
  "userId2": "uuid",
  "user1Name": "Alice",
  "user2Name": "Bob",
  "user1Image": null,
  "user2Image": null,
  "lastMessage": "Hey!",
  "lastMessageTime": "2025-03-01T09:00:00.000Z",
  "unreadCount": 2
}
```

> `unreadCount` = count of unread `Message` rows for the current requester in this conversation.

**Message JSON output** (matches `Message.fromJson`):
```json
{
  "id": "uuid",
  "conversationId": "uuid",
  "senderId": "uuid",
  "senderName": "Alice",
  "senderImage": null,
  "content": "Hey there!",
  "timestamp": "2025-03-01T09:00:00.000Z",
  "isRead": false,
  "imageUrls": []
}
```

---

### 5.7 LostFoundItem (`apps/lost_found/models.py`)

```python
class LostFoundType(TextChoices):
    LOST  = 'lost'
    FOUND = 'found'

class LostFoundItem(Model):
    id             = UUIDField(primary_key=True, default=uuid4)
    reporter       = ForeignKey(User, on_delete=CASCADE, related_name='lost_found_reports')
    title          = CharField(max_length=300)
    description    = TextField()
    location       = CharField(max_length=300)
    category       = CharField(max_length=100, null=True, blank=True)
    item_date      = DateField()
    image_urls     = JSONField(default=list)
    type           = CharField(max_length=5, choices=LostFoundType.choices)
    is_resolved    = BooleanField(default=False)
    created_at     = DateTimeField(auto_now_add=True)
    resolved_by    = ForeignKey(User, null=True, blank=True, on_delete=SET_NULL, related_name='resolved_items')
```

**JSON output** (matches `LostFoundItem.fromJson`):
```json
{
  "id": "uuid",
  "reporterId": "uuid",
  "reporterName": "Bob",
  "reporterImage": null,
  "title": "Blue Backpack",
  "description": "Lost near library",
  "location": "Library Block",
  "category": "Bags",
  "itemDate": "2025-02-28T00:00:00.000Z",
  "imageUrls": [],
  "type": "lost",
  "isResolved": false,
  "createdAt": "2025-03-01T07:00:00.000Z",
  "resolvedBy": null
}
```

---

### 5.8 Review (`apps/reviews/models.py`)

```python
class Review(Model):
    id             = UUIDField(primary_key=True, default=uuid4)
    reviewer       = ForeignKey(User, on_delete=CASCADE, related_name='reviews_given')
    target_user    = ForeignKey(User, on_delete=CASCADE, related_name='reviews_received')
    rating         = DecimalField(max_digits=2, decimal_places=1)  # 1.0 – 5.0
    comment        = TextField()
    created_at     = DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = [('reviewer', 'target_user')]  # one review per pair
```

**JSON output** (matches `Review.fromJson`):
```json
{
  "id": "uuid",
  "reviewerId": "uuid",
  "reviewerName": "Alice",
  "reviewerImage": null,
  "targetUserId": "uuid",
  "rating": 4.5,
  "comment": "Very helpful seller!",
  "createdAt": "2025-03-01T08:30:00.000Z"
}
```

> After a review is saved, recalculate and update `target_user.rating` and `target_user.reviews_count` (use a `post_save` signal).

---

## 6. API Endpoints

Base URL: `https://api.unimates.app/api/v1/`

All endpoints require `Authorization: Bearer <firebase_id_token>` unless marked **public**.

### 6.1 Users

| Method | Path | Description |
|---|---|---|
| GET | `/users/me/` | Get current user's profile |
| PATCH | `/users/me/` | Update profile (name, username, bio, university, profileImageUrl) |
| GET | `/users/{id}/` | Get any user's public profile |
| GET | `/users/search/?q=<query>` | Search users by name/username |

---

### 6.2 Community — Posts

| Method | Path | Description |
|---|---|---|
| GET | `/community/posts/?page=0&page_size=10` | Paginated feed, newest first |
| POST | `/community/posts/` | Create post |
| GET | `/community/posts/{id}/` | Get single post |
| DELETE | `/community/posts/{id}/` | Delete own post |
| POST | `/community/posts/{id}/like/` | Toggle like (like if not liked, unlike if liked) |
| GET | `/community/posts/{id}/comments/` | List comments for post |
| POST | `/community/posts/{id}/comments/` | Add comment |

**POST `/community/posts/` request body:**
```json
{
  "title": "string",
  "content": "string",
  "imageUrls": [],
  "isEvent": false,
  "eventDate": null,
  "eventLocation": null
}
```

**POST `.../like/` response:**
```json
{ "liked": true, "likesCount": 5 }
```

**POST `.../comments/` request body:**
```json
{ "content": "string" }
```

---

### 6.3 Marketplace

| Method | Path | Description |
|---|---|---|
| GET | `/marketplace/items/?category=&type=&min_price=&max_price=&q=&page=0` | Filtered + paginated listings |
| POST | `/marketplace/items/` | Create listing |
| GET | `/marketplace/items/{id}/` | Get single listing |
| PATCH | `/marketplace/items/{id}/` | Update own listing |
| DELETE | `/marketplace/items/{id}/` | Delete own listing |
| POST | `/marketplace/items/{id}/mark_sold/` | Mark as sold |
| GET | `/marketplace/items/my/?page=0` | Current user's listings |
| GET | `/marketplace/wishlist/` | Get current user's wishlisted items (returns list of `MarketplaceItem`) |
| POST | `/marketplace/wishlist/{item_id}/toggle/` | Add or remove from wishlist |

**POST `/marketplace/items/` request body:**
```json
{
  "title": "string",
  "description": "string",
  "category": "Books",
  "condition": "Good",
  "type": "sell",
  "price": 500.00,
  "exchangeTerms": null,
  "imageUrls": []
}
```

**POST `.../toggle/` response:**
```json
{ "wishlisted": true }
```

---

### 6.4 Messaging

| Method | Path | Description |
|---|---|---|
| GET | `/messaging/conversations/` | List current user's conversations |
| POST | `/messaging/conversations/` | Start or get existing conversation with another user |
| GET | `/messaging/conversations/{id}/messages/` | Get messages in conversation |
| POST | `/messaging/conversations/{id}/messages/` | Send a message |
| POST | `/messaging/conversations/{id}/mark_read/` | Mark all messages as read |

**POST `/messaging/conversations/` request body:**
```json
{ "otherUserId": "uuid" }
```
Returns the existing conversation if one already exists between the two users.

**POST `.../messages/` request body:**
```json
{ "content": "string", "imageUrls": [] }
```

---

### 6.5 Lost & Found

| Method | Path | Description |
|---|---|---|
| GET | `/lost-found/?type=lost&q=&resolved=false&page=0` | Filtered list |
| POST | `/lost-found/` | Report lost or found item |
| GET | `/lost-found/{id}/` | Get single item |
| PATCH | `/lost-found/{id}/` | Update own report |
| DELETE | `/lost-found/{id}/` | Delete own report |
| POST | `/lost-found/{id}/resolve/` | Mark as resolved (owner only) |

**POST `/lost-found/` request body:**
```json
{
  "title": "string",
  "description": "string",
  "location": "string",
  "category": "Bags",
  "itemDate": "2025-02-28",
  "type": "lost",
  "imageUrls": []
}
```

**POST `.../resolve/` request body:**
```json
{ "resolvedById": "uuid-of-user-who-found-it" }
```

---

### 6.6 Reviews

| Method | Path | Description |
|---|---|---|
| GET | `/reviews/?target_user_id={id}` | Get all reviews for a user |
| POST | `/reviews/` | Submit a review |
| GET | `/reviews/has_reviewed/?target_user_id={id}` | Check if current user already reviewed |

**POST `/reviews/` request body:**
```json
{
  "targetUserId": "uuid",
  "rating": 4.5,
  "comment": "Great experience!"
}
```

Returns `400` if current user has already reviewed `targetUserId`.

---

### 6.7 Global Search

| Method | Path | Description |
|---|---|---|
| GET | `/search/?q=<query>` | Search across all 4 content types |

**Response:**
```json
{
  "posts": [ ...Post objects ],
  "items": [ ...MarketplaceItem objects ],
  "lostFound": [ ...LostFoundItem objects ],
  "users": [ ...User objects ]
}
```

All four lists must use the same serializers as the individual module endpoints.
Return up to 10 results per category.

---

## 7. Pagination Contract

The Flutter app sends `?page=0&page_size=10` (0-indexed). Your custom paginator must honour this:

```python
# common/pagination.py
from rest_framework.pagination import PageNumberPagination as DRFPagination

class PageNumberPagination(DRFPagination):
    page_size = 10
    page_size_query_param = 'page_size'
    page_query_param = 'page'
    # Flutter sends page=0; DRF default is 1-indexed, so override page_number
    def get_page_number(self, request, paginator):
        try:
            return int(request.query_params.get(self.page_query_param, 0)) + 1
        except (ValueError, TypeError):
            return 1
```

List responses wrap results:
```json
{
  "count": 42,
  "next": "https://api.../posts/?page=1",
  "previous": null,
  "results": [ ... ]
}
```

> The Flutter app currently reads the raw list directly from `getPosts()`. When you migrate, the Flutter `MockApiService` methods that call the Django API should unwrap `response["results"]`.

---

## 8. Image Upload

The Flutter app stores `imageUrls` as a list of strings (absolute URLs).
Recommended approach: upload images from Flutter directly to **Firebase Storage** (or S3) and send the resulting URLs in the API request body. The backend stores URLs only, not the binary data.

For profile images, expose a separate endpoint:
```
PATCH /users/me/avatar/
Content-Type: multipart/form-data
Body: image file
```
Returns `{ "profileImageUrl": "https://..." }`.

---

## 9. Error Response Format

All errors must use this shape so Flutter can show them uniformly:
```json
{
  "detail": "Human-readable error message"
}
```

Standard HTTP codes:
- `400` — validation error or business rule violation (e.g. duplicate review)
- `401` — missing or invalid Firebase token
- `403` — action not allowed (e.g. editing another user's post)
- `404` — resource not found
- `409` — conflict (e.g. conversation already exists — return existing instead)

---

## 10. Flutter ↔ Django Migration Checklist

When the Django backend is ready, replace `MockApiService` calls in Flutter:

| MockApiService method | Replace with |
|---|---|
| `getPosts(page, pageSize)` | `GET /community/posts/?page=&page_size=` |
| `getPost(id)` | `GET /community/posts/{id}/` |
| `getComments(postId)` | `GET /community/posts/{id}/comments/` |
| `createPost(title, content)` | `POST /community/posts/` |
| `togglePostLike(postId)` | `POST /community/posts/{id}/like/` |
| `addComment(postId, content)` | `POST /community/posts/{id}/comments/` |
| `getMarketplaceItems(...)` | `GET /marketplace/items/?...` |
| `getMarketplaceItem(id)` | `GET /marketplace/items/{id}/` |
| `createMarketplaceListing(...)` | `POST /marketplace/items/` |
| `updateMarketplaceListing(...)` | `PATCH /marketplace/items/{id}/` |
| `deleteMarketplaceListing(id)` | `DELETE /marketplace/items/{id}/` |
| `markItemAsSold(id)` | `POST /marketplace/items/{id}/mark_sold/` |
| `getSellerListings(userId)` | `GET /marketplace/items/my/` |
| `isWishlisted(itemId)` | derived from `GET /marketplace/wishlist/` |
| `toggleWishlist(itemId)` | `POST /marketplace/wishlist/{id}/toggle/` |
| `getWishlist()` | `GET /marketplace/wishlist/` |
| `getConversations()` | `GET /messaging/conversations/` |
| `getOrCreateConversation(userId)` | `POST /messaging/conversations/` |
| `getMessages(conversationId)` | `GET /messaging/conversations/{id}/messages/` |
| `sendMessage(conversationId, content)` | `POST /messaging/conversations/{id}/messages/` |
| `markMessagesRead(conversationId)` | `POST /messaging/conversations/{id}/mark_read/` |
| `getLostFoundItems(type, q, resolved)` | `GET /lost-found/?type=&q=&resolved=` |
| `getLostFoundItem(id)` | `GET /lost-found/{id}/` |
| `createLostFoundReport(...)` | `POST /lost-found/` |
| `markLostFoundAsResolved(id, resolvedById)` | `POST /lost-found/{id}/resolve/` |
| `getReviews(targetUserId)` | `GET /reviews/?target_user_id=` |
| `hasReviewed(targetUserId)` | `GET /reviews/has_reviewed/?target_user_id=` |
| `addReview(targetUserId, rating, comment)` | `POST /reviews/` |
| `globalSearch(query)` | `GET /search/?q=` |
| `searchUsers(query)` | `GET /users/search/?q=` |
| `getUserProfile(userId)` | `GET /users/{id}/` |
| `updateUserProfile(...)` | `PATCH /users/me/` |

---

## 11. Push Notifications (FCM)

The Flutter app already integrates `firebase_messaging`. The backend should:

1. Accept a device FCM token via `PATCH /users/me/` — add a `fcmToken` field to the user.
2. Store the token in the database.
3. Send FCM push notifications server-side using `firebase-admin` in these situations:
   - New like on a post → notify post author
   - New comment on a post → notify post author
   - New message in a conversation → notify recipient
   - Lost & found item resolved → notify reporter
   - New review → notify the reviewed user

Use `firebase_admin.messaging.send()` with:
```python
message = messaging.Message(
    notification=messaging.Notification(title=title, body=body),
    token=recipient_fcm_token,
)
firebase_admin.messaging.send(message)
```

---

## 12. Django App Setup Commands

```bash
# Create project
django-admin startproject config .

# Create apps
python manage.py startapp users
python manage.py startapp community
python manage.py startapp marketplace
python manage.py startapp messaging
python manage.py startapp lost_found
python manage.py startapp reviews

# After implementing models
python manage.py makemigrations
python manage.py migrate

# Run dev server
python manage.py runserver 0.0.0.0:8000
```

Environment variables required:
```
SECRET_KEY=
DEBUG=True
DATABASE_URL=postgres://user:pass@localhost/unimates
FIREBASE_CREDENTIALS_JSON=/path/to/serviceAccountKey.json
ALLOWED_HOSTS=*
CORS_ALLOWED_ORIGINS=*
MEDIA_ROOT=/media/
```

---

## 13. Copilot Instructions for the Backend Repo

> Copy the block below into a `.github/copilot-instructions.md` file in the Django backend repository.

---

```markdown
# UniMates Django Backend — AI Agent Instructions

## What this project is
REST API backend for UniMates, a Flutter student community app.
Reads are made by a Flutter client that parses exact camelCase JSON keys.
Authentication: Firebase ID tokens verified by `firebase-admin`; no password management.

## Critical conventions
- All JSON responses must use **camelCase** keys matching the Flutter model `fromJson` methods.
- UUIDs are used as primary keys everywhere; never expose Django integer PKs.
- All datetime fields are serialised as ISO 8601 strings with `Z` suffix (UTC).
- `rating` fields are DecimalField, returned as float in JSON.
- `imageUrls` is always a JSON array of absolute URL strings, even if empty (`[]`).
- Enum string values (listing type, lost/found type) are lowercase: `"sell"`, `"lost"`, etc.

## Field name mapping (Django → JSON)
| Django field | JSON key |
|---|---|
| `profile_image` → URL | `profileImageUrl` |
| `is_verified` | `isVerified` |
| `join_date` | `joinDate` |
| `reviews_count` | `reviewsCount` |
| `likes_count` | `likesCount` |
| `comments_count` | `commentsCount` |
| `created_at` | `createdAt` |
| `image_urls` | `imageUrls` |
| `is_event` | `isEvent` |
| `event_date` | `eventDate` |
| `event_location` | `eventLocation` |
| `is_sold` | `isSold` |
| `exchange_terms` | `exchangeTerms` |
| `is_liked_by_current_user` | `isLikedByCurrentUser` |
| `last_message` | `lastMessage` |
| `last_message_time` | `lastMessageTime` |
| `unread_count` | `unreadCount` |
| `reporter.id` | `reporterId` |
| `reporter.name` | `reporterName` |
| `reporter.profile_image` | `reporterImage` |
| `resolved_by` | `resolvedBy` |
| `item_date` | `itemDate` |
| `seller.id` | `userId` |
| `seller.name` | `sellerName` |
| `seller.profile_image` | `sellerImage` |
| `reviewer.id` | `reviewerId` |
| `reviewer.name` | `reviewerName` |
| `reviewer.profile_image` | `reviewerImage` |
| `target_user.id` | `targetUserId` |

## App structure
apps/users, apps/community, apps/marketplace, apps/messaging, apps/lost_found, apps/reviews

## Authentication pattern
Every view uses `FirebaseAuthentication` from `common/authentication.py`.
`request.user` is always a `User` instance resolved from `firebase_uid`.

## Pagination
Page index is 0-based from the Flutter client (`?page=0` = first page).
The custom paginator adds 1 internally before passing to DRF.

## Signals to implement
- `PostLike` post_save/post_delete → update `Post.likes_count`
- `Comment` post_save → update `Post.comments_count`
- `Review` post_save → recalculate `target_user.rating` + `reviews_count`
- `Message` post_save → update `Conversation.last_message` + `last_message_time`

## Push notifications
Use `firebase_admin.messaging.send()` on: new like, new comment, new message, item resolved, new review.
Store FCM token in `User.fcm_token` (CharField, nullable).

## Error format
Always: `{"detail": "message"}` with standard HTTP status codes.
Return `400` for duplicate review, `403` for wrong owner, `404` for missing resource.
```
