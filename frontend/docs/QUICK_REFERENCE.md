# UniMates - Quick Reference & Cheat Sheet

## 🚀 Quick Start

### To Run the App
```bash
cd e:\Study\Coding_Projects\Flutter_Projects\Unimate
flutter run -d emulator-5554  # Or your device ID
```

### App Credentials (Test)
```
Email: test@example.com
Password: testpassword123
```

### File Structure Quick Navigation
```
Authentication:      lib/screens/auth.dart
Home Screen:         lib/screens/home.dart
App Entry:          lib/main.dart
Data Models:        lib/models/app_models.dart
Mock API:           lib/services/mock_api_service.dart
Mock Data:          assets/data/mock_*.json
```

---

## 📋 Module Checklist

### Phase 1: Authentication ✅
- [x] Email/Password Login
- [x] Email/Password Signup
- [x] Google Sign-In
- [x] Session Management
- [x] Logout

### Phase 2: Community ✅
- [x] Community Feed
- [x] Create Post
- [x] Like Posts
- [x] Comment System

### Phase 3A/3B: Marketplace ✅
- [x] Browse Items
- [x] Search & Filter
- [x] Item Details
- [x] Create Listing
- [x] Edit / Delete Listing
- [x] Mark as Sold

### Phase 4: Messaging ✅
- [x] Conversation List
- [x] Chat Interface
- [x] Mark as Read / Unread Badge
- [x] New Conversation

### Phase 5: Lost & Found ✅
- [x] Report Lost Item
- [x] Report Found Item
- [x] Browse & Search Items
- [x] Item Details
- [x] Mark as Resolved

### Phase 6: Polish & Advanced Features ⏳
- [ ] Image Upload
- [ ] Push Notifications
- [ ] Advanced Filtering
- [ ] User Ratings
- [ ] Profile Editing

---

## 🔧 Common Code Snippets

### Load Mock Data
```dart
final mockApi = MockApiService();
final posts = await mockApi.getPosts();
final items = await mockApi.getMarketplaceItems();
final lostFound = await mockApi.getLostFoundItems();
```

### Display Loading State
```dart
if (isLoading) {
  return Center(child: CircularProgressIndicator());
}
```

### Show Error Message
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Error: $errorMessage'),
    backgroundColor: Colors.red,
  ),
);
```

### Navigate to Screen
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => YourScreen()),
);
```

### Go Back
```dart
Navigator.pop(context);
```

### Create a Post Model
```dart
final post = Post(
  id: 'post_123',
  userId: 'user_456',
  authorName: 'John Doe',
  content: 'This is my post',
  imageUrls: [],
  likes: 0,
  comments: 0,
  createdAt: DateTime.now(),
);
```

### Create a Marketplace Item
```dart
final item = MarketplaceItem(
  id: 'item_123',
  userId: 'user_456',
  sellerName: 'Jane Doe',
  title: 'Used Laptop',
  description: 'Great condition',
  imageUrls: ['https://...'],
  category: 'Electronics',
  type: ListingType.sell,
  price: 50000,
  createdAt: DateTime.now(),
);
```

### Format DateTime
```dart
// Display date
final dateStr = post.createdAt.toLocal().toString().split('.')[0];

// Relative time (e.g., "2 hours ago")
Duration diff = DateTime.now().difference(post.createdAt);
if (diff.inHours > 0) {
  print('${diff.inHours} hours ago');
} else if (diff.inMinutes > 0) {
  print('${diff.inMinutes} minutes ago');
}
```

---

## 🎨 UI Components

### AppBar
```dart
AppBar(
  title: Text('Community'),
  backgroundColor: Colors.deepPurple,
  elevation: 0,
)
```

### FloatingActionButton
```dart
FloatingActionButton(
  onPressed: () { /* action */ },
  child: Icon(Icons.add),
  backgroundColor: Colors.deepPurple,
)
```

### Card
```dart
Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Text('Content here'),
  ),
)
```

### Button
```dart
ElevatedButton(
  onPressed: () { /* action */ },
  child: Text('Click Me'),
)
```

### TextField
```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Enter text',
    prefixIcon: Icon(Icons.search),
  ),
  onChanged: (value) { /* handle */ },
)
```

---

## 📊 Data Models Quick Reference

### Post
```dart
Post {
  String id
  String userId
  String authorName
  String? authorImage
  String content
  List<String> imageUrls
  int likes
  int comments
  DateTime createdAt
  bool isEvent
  String? eventDate
  String? eventLocation
}
```

### MarketplaceItem
```dart
MarketplaceItem {
  String id
  String userId
  String sellerName
  String? sellerImage
  String title
  String description
  List<String> imageUrls
  String category
  ListingType type (buy, sell, borrow, exchange)
  double? price
  String? exchangeTerms
  DateTime createdAt
  bool isSold
  double rating
  int reviewsCount
}
```

### Message
```dart
Message {
  String id
  String conversationId
  String senderId
  String senderName
  String? senderImage
  String content
  DateTime timestamp
  bool isRead
  List<String>? imageUrls
}
```

### LostFoundItem
```dart
LostFoundItem {
  String id
  String reporterId
  String reporterName
  String? reporterImage
  String title
  String description
  String location
  DateTime itemDate
  List<String> imageUrls
  LostFoundType type (lost, found)
  bool isResolved
  DateTime createdAt
  String? resolvedBy
}
```

---

## 🐛 Debugging Tips

### Print Statements
```dart
print('Debug: $variable');
print('Posts loaded: ${posts.length}');
```

### Use Flutter DevTools
```bash
flutter pub global activate devtools
devtools
# Then open browser and connect to running app
```

### Check Logs
```bash
flutter logs -d emulator-5554
```

### Rebuild App
```bash
flutter clean
flutter pub get
flutter run
```

### Hot Reload
Press 'r' in terminal while app is running

### Hot Restart
Press 'R' in terminal while app is running (full restart)

---

## 📱 Testing Scenarios

### Test Community Feed
1. Run app
2. Navigate to Community tab
3. Scroll through posts
4. Click Like button
5. Tap Comment
6. Click + to create new post

### Test Marketplace
1. Navigate to Marketplace tab
2. Search for items
3. Filter by category
4. View item details
5. Click Message Seller

### Test Messaging
1. Navigate to Messages tab
2. Tap conversation
3. Send a message
4. Verify message appears

### Test Lost & Found
1. Navigate to Lost & Found tab
2. View lost items
3. View found items
4. Report new item

---

## 🌐 API Quick Reference

### MockApiService Methods

**Community:**
- `getPosts({int page, int pageSize})` → List<Post>
- `getPost(String postId)` → Post?
- `getComments(String postId)` → List<Comment>
- `createPost(Post post)` → bool
- `togglePostLike(String postId, bool isLiked)` → bool
- `addComment(Comment comment)` → bool

**Marketplace:**
- `getMarketplaceItems({...})` → List<MarketplaceItem>
- `getMarketplaceItem(String itemId)` → MarketplaceItem?
- `createMarketplaceItem(MarketplaceItem item)` → bool
- `markItemAsSold(String itemId)` → bool
- `getCategories()` → List<String>

**Messaging:**
- `getConversations(String userId)` → List<Conversation>
- `getMessages(String conversationId)` → List<Message>
- `sendMessage(Message message)` → bool

**Lost & Found:**
- `getLostFoundItems({...})` → List<LostFoundItem>
- `reportLostFoundItem(LostFoundItem item)` → bool
- `markLostFoundAsResolved(String itemId, String? resolvedById)` → bool

**Utility:**
- `globalSearch(String query)` → Map<String, dynamic>

---

## 🎯 Common Tasks

### Add a New Screen
1. Create new file in `lib/screens/module/screen_name.dart`
2. Create StatefulWidget or StatelessWidget
3. Add navigation to bottom nav or other screen
4. Test navigation

### Add a New Widget
1. Create file in `lib/widgets/widget_name.dart`
2. Create reusable widget
3. Import where needed
4. Use multiple times

### Add Mock Data
1. Create/edit JSON file in `assets/data/`
2. Load in MockApiService
3. Return parsed objects
4. Test in UI

### Handle Errors
1. Use try-catch blocks
2. Show error dialog or snackbar
3. Log error for debugging
4. Gracefully recover state

### Show Loading State
1. Create boolean `isLoading`
2. Set true before API call
3. Check in build() method
4. Set false after response

---

## 📚 Documentation Links

- [Flutter Docs](https://flutter.dev/docs)
- [Firebase Docs](https://firebase.google.com/docs)
- [Material Design](https://material.io/design)
- [Dart Language](https://dart.dev)

---

## 🔑 Firebase Config

**Project:** chatter-via-flutter  
**Android App ID:** 1:818185250605:android:4f96576988866e8d2dd5a4  
**iOS App ID:** 1:818185250605:ios:8683f43d3669000d2dd5a4  
**Web Config:** In firebase_options.dart

---

## ⌨️ Keyboard Shortcuts (VS Code)

| Shortcut | Action |
|----------|--------|
| Ctrl+Shift+D | Format code |
| Ctrl+F | Find |
| Ctrl+H | Find & Replace |
| Ctrl+/ | Comment/Uncomment |
| Ctrl+B | Toggle sidebar |
| Ctrl+` | Toggle terminal |
| F5 | Start debugging |

---

## 📞 Quick Help

**App won't start?**
```bash
flutter clean
flutter pub get
flutter run
```

**Build error?**
Check `pubspec.yaml` - ensure all dependencies are listed

**Widget not updating?**
Check `setState()` is called or use proper state management

**API returning null?**
Check mock JSON file format matches model

**Images not loading?**
Check URL is valid and app has internet permission

---

## 🎓 Learning Resources

- Firebase Flutter: https://firebase.flutter.dev
- State Management: https://flutter.dev/docs/development/data-and-backend/state-mgmt
- UI Widgets: https://flutter.dev/docs/development/ui/widgets
- Layouts: https://flutter.dev/docs/development/ui/layout

---

**Last Updated:** January 25, 2026  
**Project Status:** Phase 1 Complete, Phase 2 Ready  
**Next Step:** Start building Community Module
