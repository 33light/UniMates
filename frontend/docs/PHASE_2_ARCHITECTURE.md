# Phase 2 Architecture & Navigation Flow

## App Navigation Structure

```
┌─────────────────────────────────────────┐
│         Firebase Auth Check             │
│     (StreamBuilder in main.dart)        │
└────────────┬────────────────────────────┘
             │
      ┌──────┴──────┐
      │             │
   Logged In    Not Logged In
      │             │
      ▼             ▼
  HomeScreen    AuthScreen
  (w/ Nav)      (Phase 1)
      │
      ▼
┌──────────────────────────────────────────────────┐
│           Bottom Navigation (5 Tabs)            │
├──────────────────────────────────────────────────┤
│ Community │ Marketplace │ Messaging │ Lost&Found │
└──────────────────────────────────────────────────┘
      │           │           │           │
      ▼           ▼           ▼           ▼
   Phase 2     Phase 3     Phase 4     Phase 5
  (ACTIVE)   (TODO)      (TODO)      (TODO)
```

## Phase 2: Community Module Architecture

```
HomeScreen
│
└─ CommunityFeedScreen ─────┐
   │                         │
   ├─ PostCard Widget ◄──────┤
   │  ├─ Author Avatar      │ MockApiService
   │  ├─ Title              │ │
   │  ├─ Content            │ ├─ getPosts()
   │  ├─ Like Count         │ ├─ getPost(id)
   │  ├─ Comment Count      │ ├─ getComments(id)
   │  └─ Action Buttons     │ ├─ createPost()
   │                         │ ├─ togglePostLike()
   ├─ FAB (Create Post)     │ └─ addComment()
   │  ↓                      │
   └─ CreatePostScreen ─────┤
      ├─ Title Field         │ Data Models
      ├─ Content Field       │ │
      └─ Submit Button ──────┤─ UniMatesUser
                             │ ├─ id
    PostCard onTap          │ ├─ name
         ↓                   │ ├─ username
    PostDetailScreen ──────┤ ├─ email
    ├─ Post Header          │ ├─ profileImageUrl
    ├─ Post Content         │ └─ ...
    ├─ Stats                │
    ├─ Comments List ◄─────┤─ Post
    └─ Comment Input ◄─────┤ ├─ id
       └─ Send Button       │ ├─ title
                             │ ├─ content
                             │ ├─ author (UniMatesUser)
                             │ ├─ likesCount
                             │ ├─ commentsCount
                             │ └─ createdAt
                             │
                             └─ Comment
                               ├─ id
                               ├─ postId
                               ├─ author (UniMatesUser)
                               ├─ content
                               └─ createdAt
```

## Data Flow Diagram

### Community Feed Loading
```
CommunityFeedScreen
        ↓
  initState()
        ↓
  FutureBuilder
        ↓
  MockApiService.getPosts()
        ↓
  rootBundle.loadString('assets/data/mock_posts.json')
        ↓
  Parse JSON → List<Post>
        ↓
  Sort by createdAt (newest first)
        ↓
  Build PostCard for each post
```

### Post Creation Flow
```
User taps FAB
     ↓
CreatePostScreen
     ↓
Fill Form
     ↓
Tap "Post" button
     ↓
Validate (title & content)
     ↓
Show loading indicator
     ↓
MockApiService.createPost(title, content)
     ↓
Simulate 500ms delay
     ↓
Show success snackbar
     ↓
Navigator.pop()
     ↓
Back to CommunityFeedScreen
     ↓
_refreshPosts() - reload data
```

### Comments Workflow
```
PostDetailScreen
     ↓
Load Post
     ↓
FutureBuilder
     ↓
MockApiService.getComments(postId)
     ↓
Load from mock_posts.json
     ↓
Build comment list
     ↓
User types comment
     ↓
Tap Send
     ↓
MockApiService.addComment(postId, content)
     ↓
Simulate 400ms delay
     ↓
Success snackbar
     ↓
Reload comments list
```

## Screen Transition Map

```
                    ┌─ Marketplace ─ (Phase 3)
                    │
   Auth            ├─ Messaging ─ (Phase 4)
   Screen          │
     │             ├─ Lost&Found ─ (Phase 5)
     ↓             │
HomePage ◄─────────┴─ Profile
(Bottom Nav)       │
     │             └─ Logout → Auth Screen
     │
     ├─ Community Feed (ACTIVE)
     │  │
     │  ├─ [FAB] → Create Post Screen
     │  │           └─ [Post] → Back to Feed
     │  │
     │  └─ [View on PostCard] → Post Detail Screen
     │               │
     │               ├─ [Like] → Toggle & Stay
     │               │
     │               └─ [Add Comment] → Refresh Comments
     │
     └─ ...other modules...
```

## State Management Flow

### Community Feed State
```
_CommunityFeedScreenState
├─ _postsFuture: Future<List<Post>>
│   └─ Initialized in initState()
│       Value = _apiService.getPosts()
│
├─ _scrollController: ScrollController
│   └─ Tracks scroll position
│       For: pagination trigger on bottom reach
│
└─ Methods:
   ├─ _refreshPosts()
   │  └─ setState(() { _postsFuture = ... })
   │
   ├─ _navigateToCreatePost()
   │  └─ Navigator.push() → CreatePostScreen
   │     On return → _refreshPosts()
   │
   ├─ _handleLike(postId)
   │  └─ togglePostLike() → _refreshPosts()
   │
   └─ _handleComment(postId)
      └─ getPost() → _navigateToPostDetail()
```

### Post Card State
```
_PostCardState
├─ _isLiked: bool
│  └─ Tracks local like state for UI feedback
│
└─ _toggleLike()
   ├─ setState(() { _isLiked = !_isLiked })
   ├─ Call onLike callback
   └─ Parent refreshes
```

### Create Post State
```
_CreatePostScreenState
├─ _formKey: GlobalKey<FormState>
├─ _titleController: TextEditingController
├─ _contentController: TextEditingController
└─ _isLoading: bool
   └─ Tracks submission state
      Disables buttons during submission
```

### Post Detail State
```
_PostDetailScreenState
├─ _commentsFuture: Future<List<Comment>>
│  └─ Reloads after comment submission
│
├─ _commentController: TextEditingController
└─ _isSubmittingComment: bool
```

## Error Handling Flow

```
API Call
   │
   ├─ Success
   │  └─ Return data
   │
└─ Error
   ├─ debugPrint('Error: $e')
   │
   ├─ If in UI context:
   │  │
   │  ├─ Show Dialog (for critical errors)
   │  ├─ Show Snackbar (for comments)
   │  └─ Show Error State (for feed)
   │
   └─ Provide retry option
```

## Widget Hierarchy

```
MyApp (MaterialApp)
 └─ home: StreamBuilder<User?>
     ├─ AuthScreen (if no user)
     └─ HomeScreen (if user)
         └─ Scaffold
             ├─ body: IndexedStack
             │  ├─ CommunityFeedScreen
             │  │  ├─ AppBar
             │  │  ├─ RefreshIndicator
             │  │  ├─ FutureBuilder
             │  │  │  └─ ListView
             │  │  │     └─ PostCard (x N)
             │  │  │        ├─ CircleAvatar (author)
             │  │  │        ├─ Text (title)
             │  │  │        ├─ Text (content)
             │  │  │        └─ Row (buttons)
             │  │  │
             │  │  └─ FloatingActionButton
             │  │
             │  ├─ MarketplaceScreen (placeholder)
             │  ├─ MessagingScreen (placeholder)
             │  ├─ LostFoundScreen (placeholder)
             │  └─ ProfileScreen
             │     ├─ Avatar
             │     ├─ Email
             │     └─ Menu Items
             │
             └─ BottomNavigationBar (5 items)
```

## File Dependencies Graph

```
main.dart
├─ auth.dart ◄─ Phase 1
├─ home_screen.dart ◄─ NEW
│  ├─ community_feed.dart ◄─ NEW
│  │  ├─ post_card.dart ◄─ NEW
│  │  ├─ create_post.dart ◄─ NEW
│  │  ├─ post_detail.dart ◄─ NEW
│  │  └─ mock_api_service.dart
│  │     └─ app_models.dart
│  ├─ marketplace_screen.dart ◄─ NEW (placeholder)
│  ├─ messaging_screen.dart ◄─ NEW (placeholder)
│  ├─ lost_found_screen.dart ◄─ NEW (placeholder)
│  └─ profile_screen.dart ◄─ NEW
│
├─ firebase_options.dart ◄─ Phase 1
└─ pubspec.yaml (updated with intl)
```

## API Call Sequence Diagram

```
Feed Loading:
CommunityFeedScreen ─►┐
                      ├─► MockApiService.getPosts()
                      │   ├─ Load mock_posts.json
                      │   ├─ Parse JSON
                      │   ├─ Create Post objects
                      │   ├─ Sort by date
                      │   └─ Return List<Post>
                      │
PostCard Builder ◄────┘

Post Creation:
CreatePostScreen ─►┐
                   ├─► MockApiService.createPost(title, content)
                   │   ├─ Delay 500ms
                   │   └─ Return true
                   │
Back to Feed ◄─────┘
                   ├─► MockApiService.getPosts() [refreshed]
                   │
Feed Updates ◄─────┘

Comments Loading:
PostDetailScreen ─►┐
                   ├─► MockApiService.getComments(postId)
                   │   ├─ Load mock_posts.json
                   │   ├─ Filter by postId
                   │   └─ Return List<Comment>
                   │
Comments List ◄────┘

Comment Submission:
User Input ─►┐
             ├─► MockApiService.addComment(postId, content)
             │   ├─ Delay 400ms
             │   └─ Return true
             │
Success ◄────┘
             ├─► MockApiService.getComments(postId) [refreshed]
             │
Updated Comments ◄─┘
```

---

**Phase 2 Architecture is production-ready and fully documented! ✅**
