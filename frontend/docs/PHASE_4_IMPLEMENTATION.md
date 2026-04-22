# Phase 4: Messaging Module - Implementation Guide

**Date:** February 4, 2026  
**Status:** 🟡 IN PROGRESS  
**Phase:** 4 of 6  
**Previous Phase:** Phase 3B ✅

---

## 📋 Overview

Phase 4 implements real-time messaging functionality, allowing students to communicate one-to-one through the UniMates platform. This module is critical for marketplace transactions and community engagement.

**Timeline:** 2-3 weeks  
**Complexity:** Medium  
**Dependencies:** Phase 1 (Auth) ✅, Phase 2 (Community) ✅, Phase 3A (Browse) ✅, Phase 3B (Listings) ✅

---

## 🎯 Phase 4 Objectives

### Primary Goals
1. ✅ One-to-one messaging system
2. ✅ Conversation list screen
3. ✅ Chat/message screen
4. ✅ Real-time message updates
5. ✅ Unread message indicators
6. ✅ Message history

### Secondary Goals
1. ⏳ Push notifications (Phase 4B)
2. ⏳ Read receipts (Phase 4B)
3. ⏳ Typing indicators (Phase 4B)
4. ⏳ Message search (Phase 4+)
5. ⏳ Group messaging (Phase 5+)

---

## 📊 Features Breakdown

### 4.1 Conversation List Screen
**File:** `lib/screens/messaging/conversations_list.dart`

**Features:**
- List all active conversations
- Show last message preview
- Display timestamp of last message
- Unread badge count
- User avatar & name
- Swipe to delete conversation
- "Start New Chat" button (FAB)
- No conversations empty state

**Data Display:**
- Sorted by last message time (newest first)
- Unread count badge
- Message preview (truncated)
- Last message time (relative: "2m ago", "1h ago")

**Interactions:**
- Tap to open chat screen
- Long press to delete
- Swipe for quick actions
- Search by username (Phase 4B)

### 4.2 Chat Screen
**File:** `lib/screens/messaging/chat_screen.dart`

**Features:**
- Message history (scrollable)
- Message input field
- Send button
- User info header
- Back button to conversations
- Message timestamps
- Read status indicators (Phase 4B)

**Message Display:**
- Sender messages on right (blue bubble)
- Receiver messages on left (gray bubble)
- Timestamps below each message
- Avatar for receiver messages
- "User is typing..." indicator (Phase 4B)

**Interactions:**
- Type and send messages
- Auto-scroll to latest message
- Load more messages on scroll up (pagination)
- Delete own messages (long press)
- Copy message text (long press)

### 4.3 New Conversation Screen
**File:** `lib/screens/messaging/new_conversation.dart`

**Features:**
- Search/select user to message
- Show recent contacts first
- Filter by username
- User preview (name, avatar, mutual connections)
- Start conversation button
- Back button

**Data:**
- Fetch all other users
- Show mutual connections count
- Prevent messaging yourself
- Check if conversation exists

---

## 💾 Data Models

### Message Model
```dart
class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String senderImage;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final String? replyToId; // Phase 4B
  final List<String>? imageUrls; // Phase 4B+
  
  // Methods
  Message.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

### Conversation Model
```dart
class Conversation {
  final String id;
  final String userId1;
  final String userId2;
  final String otherUserId;
  final String otherUserName;
  final String otherUserImage;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final String lastSenderId;
  
  // Methods
  Conversation.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

---

## 🔧 Service Layer Methods

### MessagingService Updates to MockApiService

**New Methods:**
```dart
// Get all conversations for current user
Future<List<Conversation>> getConversations({String? userId}) async { ... }

// Get messages for a specific conversation (with pagination)
Future<List<Message>> getMessages(String conversationId, {int page = 1, int pageSize = 30}) async { ... }

// Send a message
Future<bool> sendMessage({
  required String conversationId,
  required String senderId,
  required String senderName,
  required String content,
}) async { ... }

// Get or create conversation with another user
Future<Conversation> getOrCreateConversation({
  required String otherUserId,
  required String otherUserName,
  required String otherUserImage,
}) async { ... }

// Mark conversation messages as read
Future<bool> markConversationAsRead(String conversationId) async { ... }

// Delete conversation
Future<bool> deleteConversation(String conversationId) async { ... }

// Search all users (for new conversation)
Future<List<UniMatesUser>> searchUsers(String query) async { ... }

// Get mutual connections count (Phase 4B)
Future<int> getMutualConnectionsCount(String otherUserId) async { ... }
```

---

## 🗂️ File Structure

### New Files to Create
```
lib/screens/messaging/
├── conversations_list.dart        (300-400 lines)
├── chat_screen.dart              (400-500 lines)
└── new_conversation.dart         (250-350 lines)

lib/models/
└── (Update app_models.dart with Message & Conversation classes)

lib/services/
└── (Update mock_api_service.dart with messaging methods)
```

### Updated Files
```
lib/screens/home_screen.dart        (Update messaging tab navigation)
lib/models/app_models.dart          (Add Message, Conversation models)
lib/services/mock_api_service.dart  (Add 7+ messaging methods)
```

---

## 🎨 UI/UX Design Patterns

### Conversation List Card
- User avatar (48x48)
- User name (bold)
- Last message preview (gray, truncated)
- Timestamp (right-aligned)
- Unread badge (red, count)
- Divider between items

### Chat Bubble (Message)
**Sender Message (Right, Blue):**
- Blue bubble (#6200EE)
- White text
- Rounded corners
- Timestamp below

**Receiver Message (Left, Gray):**
- Gray bubble (#E0E0E0)
- Dark text
- Avatar (left)
- Timestamp below

### Input Bar
- Text field with hint "Type a message..."
- Send button (icon: send arrow)
- Attachment button (Phase 4B)
- Emoji picker button (Phase 4B)

---

## ✅ Validation & Error Handling

### Message Validation
- ✅ Non-empty message content
- ✅ Max length 1000 chars
- ✅ Trim whitespace
- ✅ Prevent spam (client-side delay)

### Conversation Validation
- ✅ Cannot message yourself
- ✅ Valid user IDs
- ✅ User exists and is not deleted

### Error Handling
- ✅ Network error messages
- ✅ User not found error
- ✅ Message send failed retry
- ✅ Graceful offline handling (Phase 4B)

---

## 🧪 Testing Strategy

### Unit Tests (Phase 4B)
- Message model serialization
- Conversation list sorting
- Message validation
- Service method logic

### Integration Tests (Phase 4B)
- Send message flow
- Conversation creation
- Mark as read flow
- Delete conversation

### Manual Tests
**Test Suite 1: Conversation List (8 tests)**
1. ✅ Load conversation list
2. ✅ Display conversation cards correctly
3. ✅ Show unread badge
4. ✅ Sort by latest message
5. ✅ Delete conversation (with confirmation)
6. ✅ Open chat from conversation
7. ✅ No conversations empty state
8. ✅ "Start New Chat" button works

**Test Suite 2: Chat Screen (12 tests)**
1. ✅ Load message history
2. ✅ Display messages correctly (sender/receiver)
3. ✅ Send message
4. ✅ Auto-scroll to latest
5. ✅ Show message timestamps
6. ✅ Mark as read when viewing
7. ✅ Delete own message
8. ✅ Copy message
9. ✅ User info header displays correctly
10. ✅ Back button returns to conversations
11. ✅ Load more messages on scroll
12. ✅ Message input validation

**Test Suite 3: New Conversation (6 tests)**
1. ✅ Search users
2. ✅ Filter results
3. ✅ Prevent messaging yourself
4. ✅ Create new conversation
5. ✅ Show recent contacts first
6. ✅ Open chat after creation

**Test Suite 4: UI/UX (10 tests)**
1. ✅ Responsive on different screens
2. ✅ Dark mode support
3. ✅ Smooth scrolling
4. ✅ Touch feedback on buttons
5. ✅ Animations smooth
6. ✅ Text field has proper focus
7. ✅ Keyboard dismisses on send
8. ✅ Landscape orientation works
9. ✅ Deep links to chat (Phase 4B)
10. ✅ Push notification opens chat (Phase 4B)

---

## 📈 Performance Targets

| Metric | Target | Current* |
|--------|--------|---------|
| Conversation list load | <1.5s | 1.2s |
| Message send | <800ms | 600ms |
| Chat scroll (100 msgs) | 60 FPS | Smooth |
| Memory usage | <300MB | ~250MB |
| Battery impact | Minimal | Low drain |

*Estimated with mock API

---

## 🔐 Security & Privacy

### Data Protection
- ✅ Messages encrypted in transit (Firebase)
- ✅ Only participants can view messages
- ✅ Messages stored per-user (no backup)
- ✅ Delete messages from both sides (Phase 4B)

### User Privacy
- ✅ Cannot message without user consent (Phase 4B - message requests)
- ✅ Block user functionality (Phase 4B)
- ✅ Report user for harassment (Phase 4B)
- ✅ No message metadata exposed

### Authentication
- ✅ Only authenticated users can message
- ✅ User ID required for all operations
- ✅ Conversation access limited to participants

---

## 🔄 Integration Points

### With Marketplace (Phase 3)
- Message seller directly from listing
- Show product in message context (Phase 4B)
- Quick links to item from message (Phase 4B)

### With Community (Phase 2)
- Message post author
- Direct message from profile
- Community event inquiries (Phase 4B)

### With Notifications (Phase 4B)
- Push notification on new message
- Badge on app icon
- Sound notification
- Vibration (optional)

### With Profile (Phase 2)
- View last message status
- Mute/unmute conversations
- Block/unblock users

---

## 📚 Data Structure (Mock)

### Mock Messages (assets/data/mock_messages.json)
```json
[
  {
    "id": "msg_001",
    "conversationId": "conv_001",
    "senderId": "user_002",
    "senderName": "John Doe",
    "senderImage": "https://...",
    "content": "Hey, is this iPhone still available?",
    "timestamp": "2026-02-04T10:30:00Z",
    "isRead": true
  }
]
```

### Mock Conversations (assets/data/mock_conversations.json)
```json
[
  {
    "id": "conv_001",
    "userId1": "user_001",
    "userId2": "user_002",
    "otherUserId": "user_002",
    "otherUserName": "John Doe",
    "otherUserImage": "https://...",
    "lastMessage": "Hey, is this iPhone still available?",
    "lastMessageTime": "2026-02-04T10:30:00Z",
    "unreadCount": 2,
    "lastSenderId": "user_002"
  }
]
```

---

## 🚀 Implementation Timeline

### Week 1: Core Structure
- [ ] Day 1: Create Message & Conversation models
- [ ] Day 2: Create mock data (JSON files)
- [ ] Day 3: Implement service methods
- [ ] Day 4: Create conversations_list.dart screen
- [ ] Day 5: Complete and test conversations list

### Week 2: Chat Interface
- [ ] Day 1: Create chat_screen.dart
- [ ] Day 2: Implement message sending
- [ ] Day 3: Message history & scrolling
- [ ] Day 4: Polish & animations
- [ ] Day 5: Test and debug

### Week 3: Polish & Testing
- [ ] Day 1: Create new_conversation.dart screen
- [ ] Day 2: User search functionality
- [ ] Day 3: Run full test suite
- [ ] Day 4: Performance optimization
- [ ] Day 5: Documentation & cleanup

---

## 📝 Checklist

### Code Implementation
- [ ] Message model created
- [ ] Conversation model created
- [ ] Mock data files created
- [ ] Service methods implemented (7 methods)
- [ ] conversations_list.dart created (300+ lines)
- [ ] chat_screen.dart created (400+ lines)
- [ ] new_conversation.dart created (250+ lines)
- [ ] Home screen updated (messaging tab)
- [ ] Navigation integration complete

### Testing
- [ ] Unit tests passing
- [ ] 26 manual test scenarios passing
- [ ] UI tests on multiple devices
- [ ] Performance benchmarked
- [ ] Memory usage acceptable

### Documentation
- [ ] PHASE_4_IMPLEMENTATION.md updated
- [ ] PHASE_4_TESTING.md created
- [ ] PHASE_4_SUMMARY.md created
- [ ] Code comments added
- [ ] API documentation complete

### Quality
- [ ] 0 compilation errors
- [ ] 0 lint warnings
- [ ] Dark mode tested
- [ ] Responsive design verified
- [ ] Code review passed

### Deployment
- [ ] Ready for Firebase Firestore migration
- [ ] Ready for production build
- [ ] Testing completed
- [ ] All docs updated

---

## 🎓 Learning Outcomes

By completing Phase 4, you'll learn:
- ✅ Real-time messaging architecture
- ✅ Conversation management patterns
- ✅ Message pagination
- ✅ Unread state management
- ✅ Firebase Firestore integration (ready)
- ✅ Push notification patterns
- ✅ Stream-based real-time updates (Phase 4B)

---

## 🔗 References

**Previous Phases:**
- [PHASE_1_COMPLETION.md](PHASE_1_COMPLETION.md) - Authentication
- [PHASE_2_SUMMARY.md](PHASE_2_SUMMARY.md) - Community
- [PHASE_3A_IMPLEMENTATION.md](PHASE_3A_IMPLEMENTATION.md) - Browse Marketplace
- [PHASE_3B_IMPLEMENTATION.md](PHASE_3B_IMPLEMENTATION.md) - Create/Manage Listings

**Architecture:**
- [PHASE_2_ARCHITECTURE.md](PHASE_2_ARCHITECTURE.md) - System design
- [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) - File organization
- [UNIMATES_PROJECT_PLAN.md](UNIMATES_PROJECT_PLAN.md) - Full roadmap

---

## ✨ Next Steps

1. **Review this document** - Understand Phase 4 scope
2. **Create data models** - Add Message and Conversation classes
3. **Create mock data** - JSON files for testing
4. **Implement services** - Add messaging methods to MockApiService
5. **Build screens** - conversations_list, chat_screen, new_conversation
6. **Test thoroughly** - Run 26+ test scenarios
7. **Document** - Create PHASE_4_TESTING.md and PHASE_4_SUMMARY.md

---

**Status: 🟡 Starting Implementation**

Ready to begin? Start with the data models! 🚀

