# UniMates App - Entity-Relationship Diagram

## Database Schema Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         UNIMATE DATABASE SCHEMA                         │
└─────────────────────────────────────────────────────────────────────────┘

                            ┌──────────────────┐
                            │   UniMatesUser   │
                            ├──────────────────┤
                            │ id (PK)          │
                            │ email            │
                            │ username         │
                            │ name             │
                            │ university       │
                            │ avatar_url       │
                            │ bio              │
                            │ rating (0-5)     │
                            │ joinDate         │
                            │ isSeller (bool)  │
                            │ verified (bool)  │
                            └──────────────────┘
                                    │
                    ┌───────────────┼───────────────┐
                    │               │               │
                    │ (1:N)         │ (1:N)         │ (1:N)
                    │               │               │
                    ▼               ▼               ▼
            ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐
            │    Post      │  │   Comment    │  │ MarketplaceItem  │
            ├──────────────┤  ├──────────────┤  ├──────────────────┤
            │ id (PK)      │  │ id (PK)      │  │ id (PK)          │
            │ authorId (FK)│  │ authorId(FK) │  │ sellerId (FK)    │
            │ title        │  │ postId (FK)  │  │ title            │
            │ content      │  │ content      │  │ description      │
            │ image_url    │  │ imageUrl     │  │ price            │
            │ likesCount   │  │ timestamp    │  │ category         │
            │ commentsCount│  │ likes        │  │ condition        │
            │ createdAt    │  │ replies      │  │ listing_type     │
            │ updatedAt    │  └──────────────┘  │ (selling/trading)│
            └──────────────┘                     │ image_urls[]     │
                    │                            │ location         │
                    │ (1:N)                      │ exchange_terms   │
                    │                            │ seller_rating    │
                    ▼                            │ createdAt        │
            ┌──────────────┐                     │ updatedAt        │
            │     Like     │                     └──────────────────┘
            ├──────────────┤                              │
            │ id (PK)      │                              │ (1:N)
            │ userId (FK)  │                              │
            │ postId (FK)  │                              ▼
            │ timestamp    │                     ┌──────────────────┐
            └──────────────┘                     │  MarketplaceReview│
                                                 ├──────────────────┤
                                                 │ id (PK)          │
                                                 │ itemId (FK)      │
                                                 │ reviewerId (FK)  │
                                                 │ rating (1-5)     │
                                                 │ comment          │
                                                 │ timestamp        │
                                                 └──────────────────┘
                                                         │
                                                         │ (N:1)
                                                         │
                                                         ▼
                                                 (User.isSeller=true)

                            ┌──────────────────┐
                            │  LostFoundItem   │
                            ├──────────────────┤
                            │ id (PK)          │
                            │ reporterId (FK)  │
                            │ title            │
                            │ description      │
                            │ status           │
                            │ (lost/found)     │
                            │ category         │
                            │ image_urls[]     │
                            │ location         │
                            │ date_lost_found  │
                            │ contact_info     │
                            │ reward_amount    │
                            │ createdAt        │
                            └──────────────────┘
                                    │
                                    │ (1:N)
                                    │
                                    ▼
                            ┌──────────────────┐
                            │  LostFoundComment│
                            ├──────────────────┤
                            │ id (PK)          │
                            │ itemId (FK)      │
                            │ userId (FK)      │
                            │ content          │
                            │ has_image        │
                            │ timestamp        │
                            └──────────────────┘

                    ┌──────────────────────────┐
                    │    Conversation (Phase4) │
                    ├──────────────────────────┤
                    │ id (PK)                  │
                    │ user1Id (FK)             │
                    │ user2Id (FK)             │
                    │ createdAt                │
                    │ updatedAt                │
                    └──────────────────────────┘
                            │
                            │ (1:N)
                            │
                            ▼
                    ┌──────────────────────────┐
                    │     Message (Phase 4)    │
                    ├──────────────────────────┤
                    │ id (PK)                  │
                    │ conversationId (FK)      │
                    │ senderId (FK)            │
                    │ content                  │
                    │ image_url                │
                    │ is_read                  │
                    │ timestamp                │
                    │ edited_at                │
                    └──────────────────────────┘
```

---

## Entity Details

### 1. **UniMatesUser**
**Primary Table - User Profile**

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | String | PK | Firebase UID |
| email | String | UNIQUE | Email address |
| username | String | UNIQUE | User handle |
| name | String | NOT NULL | Display name |
| university | String | | University/College |
| avatar_url | String | | Profile picture URL |
| bio | String | | User bio/description |
| rating | Double | 0-5 | Average seller rating |
| joinDate | DateTime | NOT NULL | Account creation date |
| isSeller | Boolean | | Marketplace seller status |
| verified | Boolean | | Email verified flag |

**Relationships:**
- 1 → N Posts (author)
- 1 → N Comments (author)
- 1 → N MarketplaceItems (seller)
- 1 → N LostFoundItems (reporter)
- 1 → N Conversations (user1, user2)

---

### 2. **Post** (Community Module - Phase 2)
**Community Posts**

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | String | PK | Unique post ID |
| authorId | String | FK | References UniMatesUser |
| title | String | NOT NULL | Post title (5-100 chars) |
| content | String | NOT NULL | Post body (10-2000 chars) |
| image_url | String | | Optional post image |
| likesCount | Integer | ≥0 | Number of likes |
| commentsCount | Integer | ≥0 | Number of comments |
| createdAt | DateTime | NOT NULL | Creation timestamp |
| updatedAt | DateTime | | Last edit timestamp |

**Relationships:**
- N → 1 UniMatesUser (author)
- 1 → N Comments
- 1 → N Likes

---

### 3. **Comment** (Community Module - Phase 2)
**Post Comments**

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | String | PK | Unique comment ID |
| postId | String | FK | References Post |
| authorId | String | FK | References UniMatesUser |
| content | String | NOT NULL | Comment text |
| imageUrl | String | | Optional image |
| timestamp | DateTime | NOT NULL | Creation time |
| likes | Integer | ≥0 | Like count |
| replies | Integer | ≥0 | Reply count (nested) |

**Relationships:**
- N → 1 Post
- N → 1 UniMatesUser (author)

---

### 4. **Like** (Community Module - Phase 2)
**Post Likes**

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | String | PK | Unique like ID |
| userId | String | FK | References UniMatesUser |
| postId | String | FK | References Post |
| timestamp | DateTime | NOT NULL | Like time |

**Constraints:**
- UNIQUE(userId, postId) - One like per user per post

---

### 5. **MarketplaceItem** (Marketplace Module - Phase 3)
**Marketplace Listings**

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | String | PK | Unique item ID |
| sellerId | String | FK | References UniMatesUser |
| title | String | NOT NULL | Item title |
| description | String | | Detailed description |
| price | Double | ≥0 | Selling price |
| category | String | | Item category |
| condition | String | | new/like-new/good/fair |
| listing_type | String | | "selling" or "trading" |
| image_urls | String[] | | Multiple images |
| location | String | | Campus/area location |
| exchange_terms | String | | For trading items |
| seller_rating | Double | 0-5 | Seller's average rating |
| available | Boolean | | Listed for sale |
| createdAt | DateTime | NOT NULL | Listing date |
| updatedAt | DateTime | | Last update |

**Relationships:**
- N → 1 UniMatesUser (seller)
- 1 → N MarketplaceReview

---

### 6. **MarketplaceReview** (Marketplace Module - Phase 3)
**Seller Reviews**

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | String | PK | Unique review ID |
| itemId | String | FK | References MarketplaceItem |
| reviewerId | String | FK | References UniMatesUser |
| rating | Integer | 1-5 | Star rating |
| comment | String | | Review text |
| timestamp | DateTime | NOT NULL | Review date |

**Constraints:**
- UNIQUE(itemId, reviewerId) - One review per buyer per item

---

### 7. **LostFoundItem** (Lost & Found Module - Phase 5)
**Lost/Found Items**

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | String | PK | Unique item ID |
| reporterId | String | FK | References UniMatesUser |
| title | String | NOT NULL | Item name |
| description | String | | Item details |
| status | String | | "lost" or "found" |
| category | String | | Item category |
| image_urls | String[] | | Photos of item |
| location | String | | Where lost/found |
| date_lost_found | DateTime | | When item was lost/found |
| contact_info | String | | Contact method |
| reward_amount | Double | ≥0 | Reward offered (if lost) |
| createdAt | DateTime | NOT NULL | Post date |

**Relationships:**
- N → 1 UniMatesUser (reporter)
- 1 → N LostFoundComment

---

### 8. **LostFoundComment** (Lost & Found Module - Phase 5)
**Lost & Found Comments/Tips**

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | String | PK | Unique comment ID |
| itemId | String | FK | References LostFoundItem |
| userId | String | FK | References UniMatesUser |
| content | String | NOT NULL | Tip/comment |
| has_image | Boolean | | Attached photo |
| timestamp | DateTime | NOT NULL | Comment date |

---

### 9. **Conversation** (Messaging Module - Phase 4)
**Direct Message Conversations**

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | String | PK | Unique conversation ID |
| user1Id | String | FK | References UniMatesUser |
| user2Id | String | FK | References UniMatesUser |
| createdAt | DateTime | NOT NULL | Conversation start |
| updatedAt | DateTime | | Last message time |

**Constraints:**
- UNIQUE(user1Id, user2Id) - One conversation per pair

---

### 10. **Message** (Messaging Module - Phase 4)
**Direct Messages**

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | String | PK | Unique message ID |
| conversationId | String | FK | References Conversation |
| senderId | String | FK | References UniMatesUser |
| content | String | NOT NULL | Message text |
| image_url | String | | Optional image |
| is_read | Boolean | | Read status |
| timestamp | DateTime | NOT NULL | Send time |
| edited_at | DateTime | | Edit timestamp |

---

## Relationship Summary

### One-to-Many (1:N) Relationships

| From | To | Description |
|------|----|----|
| UniMatesUser | Post | User authors many posts |
| UniMatesUser | Comment | User comments on many posts |
| UniMatesUser | MarketplaceItem | Seller lists many items |
| UniMatesUser | LostFoundItem | User reports many lost/found items |
| UniMatesUser | Message | User sends many messages |
| Post | Comment | Post has many comments |
| Post | Like | Post has many likes |
| MarketplaceItem | MarketplaceReview | Item receives many reviews |
| LostFoundItem | LostFoundComment | Item receives many tips |
| Conversation | Message | Conversation has many messages |

### Many-to-Many (N:N) Relationships

| Table 1 | Through | Table 2 | Description |
|---------|---------|---------|-------------|
| UniMatesUser | Like | Post | Users like posts (with Like junction table) |
| UniMatesUser | Message | UniMatesUser | Users message each other (through Conversation) |

---

## Data Flow & Access Patterns

### Phase 1: Authentication
- ✅ Users created in Firebase Auth
- ✅ User profile stored in `UniMatesUser`
- ✅ Auto-navigation based on auth state

### Phase 2: Community
- ✅ Users create `Post` with `authorId`
- ✅ Users add `Comment` to posts
- ✅ Users create `Like` records for posts
- ✅ Feed queries posts ordered by `createdAt DESC`
- ✅ Pagination: `limit=10, offset=page*10`

### Phase 3: Marketplace
- ✅ Sellers create `MarketplaceItem` with `sellerId`
- ✅ Buyers view items filtered by category/price/type
- ✅ Reviews stored in `MarketplaceReview` with buyer rating
- ✅ Seller rating calculated from average review scores

### Phase 4: Messaging
- ⏳ Users create `Conversation` (unique pair)
- ⏳ Messages stored with `senderId` and `timestamp`
- ⏳ Read status tracks message visibility
- ⏳ Ordered by timestamp DESC for chat display

### Phase 5: Lost & Found
- ⏳ Users report `LostFoundItem` (lost or found status)
- ⏳ Others add `LostFoundComment` with tips
- ⏳ Search by category, location, date range
- ⏳ Reward amount displayed for lost items

---

## Indexes (Recommended for Production)

```sql
-- UniMatesUser
CREATE INDEX idx_user_email ON UniMatesUser(email);
CREATE INDEX idx_user_username ON UniMatesUser(username);

-- Post
CREATE INDEX idx_post_author ON Post(authorId);
CREATE INDEX idx_post_created ON Post(createdAt DESC);

-- Comment
CREATE INDEX idx_comment_post ON Comment(postId);
CREATE INDEX idx_comment_author ON Comment(authorId);

-- MarketplaceItem
CREATE INDEX idx_item_seller ON MarketplaceItem(sellerId);
CREATE INDEX idx_item_category ON MarketplaceItem(category);
CREATE INDEX idx_item_price ON MarketplaceItem(price);
CREATE INDEX idx_item_created ON MarketplaceItem(createdAt DESC);

-- Message
CREATE INDEX idx_message_conversation ON Message(conversationId);
CREATE INDEX idx_message_sender ON Message(senderId);
CREATE INDEX idx_message_timestamp ON Message(timestamp DESC);

-- Conversation
CREATE INDEX idx_conversation_user1 ON Conversation(user1Id);
CREATE INDEX idx_conversation_user2 ON Conversation(user2Id);
```

---

## Notes

- **Current State:** Phases 1-3A implemented (Auth, Community, Marketplace Core)
- **Using Firebase:** Auth ✅, Firestore ready for Phase 3B+
- **Mock API:** JSON files for development, Firestore for production
- **Null Safety:** All Dart models use null safety (?)
- **Timestamps:** ISO 8601 format (DateTime)
- **IDs:** Firebase UIDs for users, auto-generated for posts/items
