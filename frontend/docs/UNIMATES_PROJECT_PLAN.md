# UniMates Mobile App - Project Plan & Implementation Roadmap

## 📋 Executive Summary

**Project Name:** UniMates  
**Type:** Cross-platform Mobile Application (Flutter)  
**Target Users:** University Students  
**Primary Purpose:** Centralized platform combining student community engagement with a trusted peer-to-peer marketplace  

### Core Value Proposition
Students currently juggle multiple apps (WhatsApp, Instagram, Marketplace apps). UniMates eliminates fragmentation by providing:
- ✅ Unified student community space
- ✅ Secure verified marketplace (buy/sell/borrow/exchange)
- ✅ Real-time messaging
- ✅ Event management
- ✅ Lost & Found system
- ✅ All in one verified, student-only ecosystem

---

## 🎯 Project Objectives

1. **Community Engagement**
   - Students can create posts and interact
   - Real-time feed with likes/comments
   - Event announcements

2. **Marketplace Trust**
   - Verified student-only access
   - Buy, sell, borrow, exchange items
   - Secure in-app messaging for transactions

3. **Real-time Communication**
   - One-to-one messaging between students
   - Push notifications for updates

4. **Campus Support**
   - Lost & Found system
   - Item recovery assistance

5. **User Verification**
   - University email verification
   - Account verification before full access

---

## 🏗️ Application Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter Mobile App                   │
├─────────────────────────────────────────────────────────┤
│  Presentation Layer (UI/UX)                             │
│  ├─ Auth Screens (Login/Signup)                         │
│  ├─ Community Module (Feed, Posts, Events)              │
│  ├─ Marketplace Module (Items, Search, Filters)         │
│  ├─ Messaging Module (Chats, Notifications)             │
│  ├─ Lost & Found Module                                 │
│  └─ Profile Management                                  │
├─────────────────────────────────────────────────────────┤
│  Business Logic Layer (State Management)                │
│  ├─ Provider/Riverpod for state                         │
│  ├─ Form validation                                     │
│  └─ Business logic                                      │
├─────────────────────────────────────────────────────────┤
│  Service Layer (API & Data)                             │
│  ├─ API Service (temporary mock for now)                │
│  ├─ Authentication Service                              │
│  ├─ Firebase Realtime Updates                           │
│  └─ Local Storage (SharedPreferences)                   │
├─────────────────────────────────────────────────────────┤
│  External Services                                      │
│  ├─ Firebase (Auth, Firestore, Storage, FCM)            │
│  ├─ Temporary Mock Backend (JSON data)                  │
│  └─ Image Storage (Firebase Storage)                    │
└─────────────────────────────────────────────────────────┘
```

---

## 📱 Feature Breakdown & Implementation Status

### Phase 1: Foundation (COMPLETED ✅)
- ✅ User Authentication (Email/Password, Google Sign-In)
- ✅ User Verification via Firebase
- ✅ Home Screen Placeholder
- ✅ User Profile Management

### Phase 2: Core Features (COMPLETED ✅)
- ✅ Community Module (Posts, Feed, Comments, Likes)
- ✅ Marketplace Module (Browse, Create, Edit, Delete, Mark Sold)
- ✅ Messaging System (Conversations, Chat, Mark as Read)
- ✅ Lost & Found Module (Report, Browse, Resolve)
- ⏳ Push Notifications (Phase 6)

---

## 🎬 User Journey Walkthrough

### 👤 User Flow: First-Time Experience

```
Start App
   ↓
[Loading: Check Firebase Auth]
   ↓
No Session? → Auth Screen
   ├─ Option 1: Sign Up with Email
   │  ├─ Enter university email
   │  ├─ Set password (8+ chars)
   │  ├─ Verify email
   │  └─ Go to Home
   │
   ├─ Option 2: Sign In with Google
   │  ├─ Select Google account
   │  ├─ Auto-create account
   │  └─ Go to Home
   │
   └─ Option 3: Existing User Login
      ├─ Email + Password
      └─ Go to Home
   
   ↓
Yes Session? → Home Screen
   ├─ Community Tab (Default)
   ├─ Marketplace Tab
   ├─ Messages Tab
   ├─ Lost & Found Tab
   └─ Profile Tab
```

### 📌 Detailed Tab Navigation

#### **Tab 1: Community**
```
Community Home
├─ Feed (Real-time posts)
│  ├─ Create Post Button
│  │  ├─ Text input
│  │  ├─ Add images
│  │  └─ Post
│  │
│  └─ Post Items
│     ├─ Author profile
│     ├─ Content + Images
│     ├─ Like button
│     ├─ Comment button
│     └─ View Comments
│
└─ Events Section
   ├─ Upcoming Events
   ├─ Event Details
   └─ Join Event Button
```

#### **Tab 2: Marketplace**
```
Marketplace Home
├─ Search & Filter
│  ├─ Search box
│  ├─ Category filter (Electronics, Books, Furniture, etc.)
│  ├─ Price range
│  └─ Listing type (Buy/Sell/Borrow/Exchange)
│
└─ Item Listings
   ├─ Item Card
   │  ├─ Image
   │  ├─ Title
   │  ├─ Price/Terms
   │  ├─ Seller name
   │  └─ Tap to View Details
   │
   └─ Item Details Screen
      ├─ Full images gallery
      ├─ Detailed description
      ├─ Seller profile
      ├─ "Message Seller" button
      └─ "Add to Wishlist" button

Create Listing Screen
├─ Item title
├─ Category
├─ Description
├─ Listing type (Buy/Sell/Borrow/Exchange)
├─ Price (if selling)
├─ Images upload
└─ Post button
```

#### **Tab 3: Messages**
```
Messages Home
├─ Conversation List
│  ├─ Recent conversations
│  ├─ Unread badge count
│  └─ Tap to open chat
│
└─ Chat Screen
   ├─ Conversation header (other user)
   ├─ Message list
   │  ├─ Sent messages (right)
   │  ├─ Received messages (left)
   │  └─ Timestamps
   │
   └─ Input area
      ├─ Message text field
      ├─ Send button
      └─ (Optional) Image attachment
```

#### **Tab 4: Lost & Found**
```
Lost & Found Home
├─ Two sections
│  ├─ Lost Items
│  └─ Found Items
│
├─ List of items
│  ├─ Item image
│  ├─ Description
│  ├─ Where/When lost
│  ├─ Posted by (profile)
│  └─ Contact button
│
└─ Report New Item
   ├─ Lost or Found?
   ├─ Item description
   ├─ Location details
   ├─ Images
   ├─ Contact info
   └─ Post button
```

#### **Tab 5: Profile**
```
Profile Screen
├─ User Info Section
│  ├─ Avatar
│  ├─ Name
│  ├─ University email
│  ├─ Verification status (✓ Verified)
│  └─ Join date
│
├─ User Stats
│  ├─ Posts count
│  ├─ Marketplace items
│  ├─ Rating/Reviews
│  └─ Response time
│
├─ Quick Links
│  ├─ My Posts
│  ├─ My Marketplace Items
│  ├─ My Listings
│  ├─ Saved Items
│  └─ Settings
│
└─ Action Buttons
   ├─ Edit Profile
   ├─ Settings
   └─ Logout
```

---

## 🛠️ Technical Implementation Plan

### Current Stack
```
Frontend:        Flutter + Dart
UI Framework:    Material 3
State Management: Provider (recommended) / Riverpod
Auth:            Firebase Authentication
Database (Temp): Local JSON + Firestore (Firebase)
Real-time DB:    Firebase Firestore
Storage:         Firebase Storage
Notifications:   Firebase Cloud Messaging (FCM)
```

### Temporary Backend Strategy (While Django Backend Not Ready)

Since the backend is not yet available, we'll implement:

**Option 1: Mock Data Approach (Recommended for MVP)**
```
- Local JSON files in assets/ folder
- Simulated API responses
- Local storage for user data
- Easy transition to real backend later
```

**Option 2: Firebase-Only Approach**
```
- Use Firebase Firestore as temporary backend
- Implement security rules
- Real-time data synchronization
- No server needed
```

---

## 📊 Module Breakdown & Implementation Plan

### Module 1: Community Module

**Features:**
- Create text/image posts
- Real-time feed
- Like posts
- Comment on posts
- View event announcements

**Data Structure:**
```dart
class Post {
  String id;
  String userId;
  String authorName;
  String authorImage;
  String content;
  List<String> imageUrls;
  int likes;
  int comments;
  DateTime createdAt;
  bool isEvent; // For event posts
}

class Comment {
  String id;
  String postId;
  String userId;
  String authorName;
  String content;
  DateTime createdAt;
}
```

**Screens to Create:**
- `community_feed.dart` - Main feed display
- `create_post.dart` - Post creation form
- `post_detail.dart` - Post with comments
- `post_item.dart` - Reusable post widget

**Temporary Implementation:**
- Mock posts in `assets/data/mock_posts.json`
- Local list stored in Provider state
- Simulate post creation (add to local list)

---

### Module 2: Marketplace Module

**Features:**
- List items for sale/borrow/exchange
- Search and filter items
- View item details
- Message seller
- Add to wishlist

**Data Structure:**
```dart
class MarketplaceItem {
  String id;
  String userId;
  String sellerName;
  String sellerImage;
  String title;
  String description;
  List<String> imageUrls;
  String category; // Electronics, Books, Furniture, etc.
  ListingType type; // Buy, Sell, Borrow, Exchange
  double? price; // null for borrow/exchange
  String? exchangeTerms;
  DateTime createdAt;
  bool isSold;
  double rating;
}

enum ListingType {
  buy,
  sell,
  borrow,
  exchange
}
```

**Screens to Create:**
- `marketplace_home.dart` - Listings grid
- `marketplace_search.dart` - Search & filter
- `item_detail.dart` - Full item details
- `create_listing.dart` - Create new listing
- `my_listings.dart` - User's listings

**Temporary Implementation:**
- Mock items in `assets/data/mock_items.json`
- Local storage for user's listings
- Simulate listing creation

---

### Module 3: Messaging Module

**Features:**
- One-to-one conversations
- Real-time message updates
- Message history
- Unread indicators
- Notifications

**Data Structure:**
```dart
class Conversation {
  String id;
  String userId1;
  String userId2;
  String user1Name;
  String user2Name;
  String lastMessage;
  DateTime lastMessageTime;
  int unreadCount;
}

class Message {
  String id;
  String conversationId;
  String senderId;
  String senderName;
  String content;
  DateTime timestamp;
  bool isRead;
}
```

**Screens to Create:**
- `messages_list.dart` - Conversation list
- `chat_screen.dart` - Individual chat
- `new_message.dart` - Start new conversation

**Temporary Implementation:**
- Mock conversations in memory
- Local storage for messages
- Simulate real-time updates with delays

---

### Module 4: Lost & Found Module

**Features:**
- Report lost items
- Report found items
- Search lost/found items
- Contact finder/reporter
- Mark as recovered

**Data Structure:**
```dart
class LostFoundItem {
  String id;
  String reporterId;
  String reporterName;
  String reporterImage;
  String title;
  String description;
  String location;
  DateTime lostFoundDate;
  List<String> imageUrls;
  LostFoundType type; // Lost or Found
  bool isResolved;
}

enum LostFoundType {
  lost,
  found
}
```

**Screens to Create:**
- `lost_found_home.dart` - Items list
- `report_item.dart` - Report lost/found
- `item_detail.dart` - Item details

**Temporary Implementation:**
- Mock items in `assets/data/mock_lost_found.json`
- Local storage for reported items

---

## 📁 Proposed Folder Structure

```
lib/
├─ main.dart
├─ firebase_options.dart
│
├─ models/
│  ├─ user_model.dart
│  ├─ post_model.dart
│  ├─ marketplace_item_model.dart
│  ├─ message_model.dart
│  ├─ lost_found_model.dart
│  └─ conversation_model.dart
│
├─ services/
│  ├─ auth_service.dart
│  ├─ api_service.dart (mock API)
│  ├─ messaging_service.dart
│  ├─ storage_service.dart
│  └─ notification_service.dart
│
├─ providers/
│  ├─ auth_provider.dart
│  ├─ user_provider.dart
│  ├─ community_provider.dart
│  ├─ marketplace_provider.dart
│  ├─ messaging_provider.dart
│  └─ lost_found_provider.dart
│
├─ screens/
│  ├─ auth/
│  │  ├─ auth_screen.dart
│  │  └─ login_screen.dart
│  │
│  ├─ home/
│  │  ├─ home_screen.dart (main tab navigation)
│  │  └─ bottom_nav.dart
│  │
│  ├─ community/
│  │  ├─ community_feed.dart
│  │  ├─ create_post.dart
│  │  ├─ post_detail.dart
│  │  └─ events_page.dart
│  │
│  ├─ marketplace/
│  │  ├─ marketplace_home.dart
│  │  ├─ marketplace_search.dart
│  │  ├─ item_detail.dart
│  │  ├─ create_listing.dart
│  │  └─ my_listings.dart
│  │
│  ├─ messaging/
│  │  ├─ messages_list.dart
│  │  ├─ chat_screen.dart
│  │  └─ new_message.dart
│  │
│  ├─ lost_found/
│  │  ├─ lost_found_home.dart
│  │  ├─ report_item.dart
│  │  └─ lost_found_detail.dart
│  │
│  └─ profile/
│     ├─ profile_screen.dart
│     ├─ edit_profile.dart
│     ├─ settings.dart
│     └─ my_posts.dart
│
├─ widgets/
│  ├─ post_card.dart
│  ├─ item_card.dart
│  ├─ message_bubble.dart
│  ├─ bottom_navigation.dart
│  └─ loading_widget.dart
│
└─ utils/
   ├─ constants.dart
   ├─ theme.dart
   ├─ validators.dart
   └─ extensions.dart

assets/
├─ data/
│  ├─ mock_posts.json
│  ├─ mock_items.json
│  ├─ mock_lost_found.json
│  └─ mock_users.json
│
└─ images/
   ├─ community_icon.png
   ├─ marketplace_icon.png
   └─ ...

pubspec.yaml
└─ Add required dependencies
```

---

## 🔄 Development Timeline & Milestones

### Week 1: Setup & Planning
- ✅ Authentication (Already done!)
- Create project structure
- Set up state management (Provider)
- Create mock data files

### Week 2-3: Community Module
- Build community feed
- Implement post creation
- Add comments system
- Real-time updates

### Week 4-5: Marketplace Module
- Build marketplace UI
- Search & filter functionality
- Item creation form
- Item detail screens

### Week 6: Messaging Module
- Conversation list
- Chat interface
- Real-time messaging
- Notifications

### Week 7: Lost & Found Module
- Report interface
- Search functionality
- Contact system

### Week 8: Profile & Settings
- User profile
- Edit profile
- Settings page
- Preferences

### Week 9-10: Integration & Testing
- Connect all modules
- User testing
- Bug fixes
- Performance optimization

### Week 11-12: Documentation & Backend Integration
- Prepare for backend integration
- Documentation
- Code refactoring
- Final testing

---

## 🚀 Implementation Strategy: Temporary Backend

Since Django backend isn't ready, here's the recommended approach:

### Strategy 1: Mock JSON Data (Fastest)

```dart
// assets/data/mock_posts.json
{
  "posts": [
    {
      "id": "1",
      "userId": "user_1",
      "authorName": "Ali Ahmed",
      "authorImage": "https://...",
      "content": "Looking for study group for programming",
      "imageUrls": [],
      "likes": 24,
      "comments": 5,
      "createdAt": "2026-01-25T10:30:00Z",
      "isEvent": false
    }
  ]
}
```

**Advantages:**
- Simple to implement
- Easy to test features
- Smooth transition to backend
- All data locally available

### Strategy 2: Firebase Firestore (Scalable)

```dart
// Initialize Firestore collections
- posts/
- marketplace_items/
- messages/
- conversations/
- users/
- lost_found_items/
```

**Advantages:**
- Real scalability
- Real-time features work immediately
- Cloud storage
- Authentication already integrated

---

## 🎨 UI/UX Considerations

### Design Principles
1. **Student-Friendly:** Simple, fast, intuitive
2. **Trust-Based:** Show verification badges
3. **Safe:** Clear buyer/seller protections
4. **Accessible:** Clear typography, good contrast
5. **Responsive:** Works on all screen sizes

### Color Scheme (University Theme)
```
Primary Color: Deep Blue (#1E3C72)
Secondary Color: University Gold (#FFB81C)
Accent Color: Student Green (#4CAF50)
Background: Light Gray (#F5F5F5)
Text: Dark Gray (#212121)
```

---

## 📊 Suggested Enhancements & Features (Future)

1. **Ratings & Reviews System**
   - Seller/item ratings
   - Review display
   - Reputation building

2. **Search Recommendations**
   - Popular items
   - Based on browsing history
   - Personalized suggestions

3. **Advanced Marketplace**
   - Wishlist functionality
   - Price alerts
   - Item availability notifications

4. **Community Moderation**
   - Admin dashboard
   - Content flags
   - User reports

5. **Social Features**
   - Student profiles with about section
   - Follow other students
   - Activity feeds

6. **Analytics**
   - User engagement metrics
   - Popular categories
   - Trending items/posts

---

## ⚠️ Recommendations & Best Practices

### Security
- ✅ Always verify university email
- ✅ Use HTTPS for all API calls
- ✅ Validate input on frontend & backend
- ✅ Never store passwords in local storage
- ✅ Use Firebase security rules

### Performance
- Use image compression for uploads
- Implement pagination for lists
- Cache frequently accessed data
- Lazy load images in lists
- Minimize API calls

### User Experience
- Show loading indicators
- Handle network errors gracefully
- Provide feedback for actions
- Clear error messages
- Intuitive navigation

### Testing
- Test all authentication flows
- Test each module independently
- Test with mock data
- User acceptance testing
- Performance testing

---

## 🔄 Backend Integration Path

When Django backend becomes available:

1. **Replace Mock Services**
   - Update `api_service.dart`
   - Point to backend endpoints
   - Keep same data models

2. **API Endpoints Needed**
   ```
   Authentication:
   - POST /auth/register
   - POST /auth/login
   - POST /auth/verify-email
   
   Community:
   - GET /posts (with pagination)
   - POST /posts
   - POST /posts/{id}/like
   - POST /posts/{id}/comment
   
   Marketplace:
   - GET /marketplace/items (with filters)
   - POST /marketplace/items
   - GET /marketplace/items/{id}
   
   Messaging:
   - GET /conversations
   - POST /messages
   - GET /messages/{conversationId}
   
   Lost & Found:
   - GET /lost-found
   - POST /lost-found
   - PATCH /lost-found/{id}/mark-resolved
   ```

3. **Firebase Integration**
   - Real-time listeners for messages
   - Push notifications
   - File storage

---

## 📝 Success Metrics

Track these metrics to measure project success:

1. **Functionality**
   - All modules working
   - No critical bugs
   - Smooth navigation

2. **Performance**
   - App loads in < 3 seconds
   - Feed scrolls smoothly (60 fps)
   - Messages send in < 2 seconds

3. **User Experience**
   - Intuitive navigation
   - Clear error messages
   - Responsive design

4. **Code Quality**
   - Modular architecture
   - Proper documentation
   - Clean code practices

---

## 🎓 Academic Evaluation Points

This project demonstrates:
- ✅ Full software development lifecycle
- ✅ Cross-platform mobile development (Flutter)
- ✅ Real-world problem solving
- ✅ User-centered design
- ✅ Security implementation
- ✅ Real-time features
- ✅ State management
- ✅ API integration patterns
- ✅ Testing methodology
- ✅ Scalable architecture

---

## Next Steps

1. ✅ **Complete:** Authentication & Home screen base
2. **Next:** Create models and data structures
3. **Then:** Build Community module with mock data
4. **Follow:** Marketplace module
5. **Then:** Messaging system
6. **Then:** Lost & Found
7. **Finally:** Integration & testing

---

**Project Status:** Ready for Module Development
**Current Progress:** 15% (Authentication complete)
**Est. Completion:** 12 weeks with current pace
