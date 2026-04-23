import 'dart:convert';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:unimates/models/app_models.dart';
import 'package:unimates/services/notification_service.dart';

/// API Service -- connects to the Django REST backend.
/// Keeps the same public interface as the old MockApiService
/// so no screen changes are required.
class MockApiService {
  static final MockApiService _instance = MockApiService._internal();
  factory MockApiService() => _instance;
  MockApiService._internal();
  static MockApiService get instance => _instance;

  // -- Base URL --------------------------------------------------------------
  // Android emulator          -> 10.0.2.2
  // iOS simulator / web / Windows desktop -> 127.0.0.1
  // Physical Android/iOS device -> your PC's local IP (e.g. 192.168.1.5)
  static const String _base = 'http://welcomemate.pythonanywhere.com/api/v1';

  // In-memory wishlist for instant synchronous UI feedback
  final Set<String> _wishlistedItemIds = {};

  // In-memory cache for screens that get recreated on tab switch
  List<LostFoundItem>? _cachedLostItems;
  List<LostFoundItem>? _cachedFoundItems;
  List<MarketplaceItem>? _cachedMarketplaceItems;
  List<Post>? _cachedCommunityPosts;
  String? _cachedCurrentUserDjangoId;

  /// Returns cached items for a given type (empty list if not yet fetched).
  List<LostFoundItem> getCachedLostFoundItems(LostFoundType type) {
    if (type == LostFoundType.lost) return _cachedLostItems ?? [];
    return _cachedFoundItems ?? [];
  }

  List<MarketplaceItem> getCachedMarketplaceItems() =>
      _cachedMarketplaceItems ?? [];

  List<Post> getCachedCommunityPosts() => _cachedCommunityPosts ?? [];

  /// Returns the current user's Django UUID (fetches once and caches).
  Future<String?> getCurrentUserDjangoId() async {
    if (_cachedCurrentUserDjangoId != null) return _cachedCurrentUserDjangoId;
    await getUserProfile(FirebaseAuth.instance.currentUser?.uid ?? '');
    return _cachedCurrentUserDjangoId;
  }

  // -- HTTP helpers ----------------------------------------------------------

  Future<Map<String, String>> _headers() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _get(String path,
      {Map<String, String>? params}) async {
    final uri =
        Uri.parse('$_base$path').replace(queryParameters: params);
    return http.get(uri, headers: await _headers());
  }

  Future<http.Response> _post(
      String path, Map<String, dynamic> body) async {
    return http.post(Uri.parse('$_base$path'),
        headers: await _headers(), body: jsonEncode(body));
  }

  Future<http.Response> _patch(
      String path, Map<String, dynamic> body) async {
    return http.patch(Uri.parse('$_base$path'),
        headers: await _headers(), body: jsonEncode(body));
  }

  Future<http.Response> _delete(String path) async {
    return http.delete(Uri.parse('$_base$path'),
        headers: await _headers());
  }

  /// Uploads a single file and returns its public URL.
  Future<String> uploadImage(String filePath, {String folder = 'uploads'}) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    final uri = Uri.parse('$_base/upload/');
    final req = http.MultipartRequest('POST', uri);
    if (token != null) req.headers['Authorization'] = 'Bearer $token';
    req.fields['folder'] = folder;
    req.files.add(await http.MultipartFile.fromPath('file', filePath));
    final streamed = await req.send();
    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode == 201) {
      return jsonDecode(body)['url'] as String;
    }
    throw Exception('Upload failed (${streamed.statusCode}): $body');
  }

  /// Unwrap paginated `{"count": N, "results": [...]}` or plain list.
  List<dynamic> _results(http.Response r) {
    if (r.statusCode >= 200 && r.statusCode < 300) {
      final data = jsonDecode(r.body);
      if (data is Map && data.containsKey('results')) {
        return data['results'] as List;
      }
      if (data is List) return data;
    }
    return [];
  }

  // =====================
  // Community API Methods
  // =====================

  Future<List<Post>> getPosts({int page = 0, int pageSize = 10}) async {
    try {
      final r = await _get('/community/posts/', params: {
        'page': '$page',
        'page_size': '$pageSize',
      });
      return _results(r).map((j) => Post.fromJson(j)).toList();
    } catch (e) {
      debugPrint('getPosts error: $e');
      return [];
    }
  }

  Future<Post?> getPost(String postId) async {
    try {
      final r = await _get('/community/posts/$postId/');
      if (r.statusCode == 200) return Post.fromJson(jsonDecode(r.body));
    } catch (e) {
      debugPrint('getPost error: $e');
    }
    return null;
  }

  Future<List<Comment>> getComments(String postId) async {
    try {
      final r =
          await _get('/community/posts/$postId/comments/');
      return _results(r).map((j) => Comment.fromJson(j)).toList();
    } catch (e) {
      debugPrint('getComments error: $e');
      return [];
    }
  }

  Future<bool> createPost({
    required String title,
    required String content,
  }) async {
    try {
      final r = await _post('/community/posts/', {
        'title': title,
        'content': content,
        'imageUrls': [],
        'isEvent': false,
      });
      return r.statusCode == 201;
    } catch (e) {
      debugPrint('createPost error: $e');
      return false;
    }
  }

  Future<bool> togglePostLike(String postId) async {
    try {
      final r = await _post('/community/posts/$postId/like/', {});
      if (r.statusCode == 200) {
        final liked = jsonDecode(r.body)['liked'] as bool;
        if (liked) {
          NotificationService.instance.addLocalNotification(
            type: 'like',
            title: 'New Like',
            body: 'Someone liked your post',
          );
        }
        return true;
      }
    } catch (e) {
      debugPrint('togglePostLike error: $e');
    }
    return false;
  }

  Future<bool> addComment({
    required String postId,
    required String content,
  }) async {
    try {
      if (content.trim().isEmpty) return false;
      final r = await _post(
          '/community/posts/$postId/comments/', {'content': content.trim()});
      if (r.statusCode == 201) {
        NotificationService.instance.addLocalNotification(
          type: 'comment',
          title: 'New Comment',
          body: 'Someone commented on your post',
        );
        return true;
      }
    } catch (e) {
      debugPrint('addComment error: $e');
    }
    return false;
  }

  // =====================
  // Marketplace API Methods
  // =====================

  Future<List<MarketplaceItem>> getMarketplaceItems({
    String? category,
    ListingType? type,
    double? minPrice,
    double? maxPrice,
    String? searchQuery,
    int page = 0,
    int pageSize = 10,
  }) async {
    try {
      final r = await _get('/marketplace/items/', params: {
        'page': '$page',
        'page_size': '$pageSize',
        if (category != null && category.isNotEmpty) 'category': category,
        if (type != null) 'type': type.toString().split('.').last,
        if (minPrice != null) 'min_price': '$minPrice',
        if (maxPrice != null) 'max_price': '$maxPrice',
        if (searchQuery != null && searchQuery.isNotEmpty) 'q': searchQuery,
      });
      return _results(r).map((j) => MarketplaceItem.fromJson(j)).toList();
    } catch (e) {
      debugPrint('getMarketplaceItems error: $e');
      return [];
    }
  }

  Future<MarketplaceItem?> getMarketplaceItem(String itemId) async {
    try {
      final r = await _get('/marketplace/items/$itemId/');
      if (r.statusCode == 200) {
        return MarketplaceItem.fromJson(jsonDecode(r.body));
      }
    } catch (e) {
      debugPrint('getMarketplaceItem error: $e');
    }
    return null;
  }

  Future<bool> createMarketplaceItem(MarketplaceItem item) async {
    return createMarketplaceListing(
      title: item.title,
      description: item.description,
      category: item.category,
      type: item.type,
      price: item.price,
      exchangeTerms: item.exchangeTerms,
      imageUrls: item.imageUrls,
      condition: item.condition,
    );
  }

  Future<bool> createMarketplaceListing({
    required String title,
    required String description,
    required String category,
    required ListingType type,
    double? price,
    String? exchangeTerms,
    List<String> imageUrls = const [],
    String? condition,
  }) async {
    try {
      final r = await _post('/marketplace/items/', {
        'title': title,
        'description': description,
        'category': category,
        'type': type.toString().split('.').last,
        if (price != null) 'price': price,
        if (exchangeTerms != null) 'exchangeTerms': exchangeTerms,
        'imageUrls': imageUrls,
        if (condition != null) 'condition': condition,
      });
      return r.statusCode == 201;
    } catch (e) {
      debugPrint('createMarketplaceListing error: $e');
      return false;
    }
  }

  Future<List<MarketplaceItem>> getSellerListings({
    String? sellerId,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      final r = await _get('/marketplace/items/my/',
          params: {'page': '$page', 'page_size': '$pageSize'});
      return _results(r).map((j) => MarketplaceItem.fromJson(j)).toList();
    } catch (e) {
      debugPrint('getSellerListings error: $e');
      return [];
    }
  }

  Future<bool> updateMarketplaceListing({
    required String listingId,
    required String title,
    required String description,
    required String category,
    required ListingType type,
    double? price,
    String? exchangeTerms,
    List<String> imageUrls = const [],
    String? condition,
  }) async {
    try {
      final r = await _patch('/marketplace/items/$listingId/', {
        'title': title,
        'description': description,
        'category': category,
        'type': type.toString().split('.').last,
        if (price != null) 'price': price,
        if (exchangeTerms != null) 'exchangeTerms': exchangeTerms,
        'imageUrls': imageUrls,
        if (condition != null) 'condition': condition,
      });
      return r.statusCode == 200;
    } catch (e) {
      debugPrint('updateMarketplaceListing error: $e');
      return false;
    }
  }

  Future<bool> deleteMarketplaceListing(String listingId) async {
    try {
      final r = await _delete('/marketplace/items/$listingId/');
      return r.statusCode == 204;
    } catch (e) {
      debugPrint('deleteMarketplaceListing error: $e');
      return false;
    }
  }

  Future<bool> markListingAsSold(String listingId) async =>
      markItemAsSold(listingId);

  Future<bool> markItemAsSold(String itemId) async {
    try {
      final r =
          await _post('/marketplace/items/$itemId/mark_sold/', {});
      return r.statusCode == 200;
    } catch (e) {
      debugPrint('markItemAsSold error: $e');
      return false;
    }
  }

  // =====================
  // Messaging API Methods
  // =====================

  Future<List<Conversation>> getConversations(String userId) async {
    try {
      final r = await _get('/messaging/conversations/');
      return _results(r).map((j) => Conversation.fromJson(j)).toList();
    } catch (e) {
      debugPrint('getConversations error: $e');
      return [];
    }
  }

  Future<List<Message>> getMessages(String conversationId) async {
    try {
      final r = await _get(
          '/messaging/conversations/$conversationId/messages/');
      return _results(r).map((j) => Message.fromJson(j)).toList();
    } catch (e) {
      debugPrint('getMessages error: $e');
      return [];
    }
  }

  Future<bool> sendMessage(Message message) async {
    try {
      final r = await _post(
          '/messaging/conversations/${message.conversationId}/messages/',
          {
            'content': message.content,
            'imageUrls': message.imageUrls ?? [],
          });
      return r.statusCode == 201;
    } catch (e) {
      debugPrint('sendMessage error: $e');
      return false;
    }
  }

  Future<Conversation> getOrCreateConversation({
    required String otherUserId,
    required String otherUserName,
    required String otherUserImage,
    required String currentUserId,
    required String currentUserName,
  }) async {
    final r = await _post(
        '/messaging/conversations/', {'otherUserId': otherUserId});
    if (r.statusCode == 200 || r.statusCode == 201) {
      return Conversation.fromJson(jsonDecode(r.body));
    }
    throw Exception('Failed to get or create conversation');
  }

  Future<bool> markConversationAsRead(String conversationId) async {
    try {
      final r = await _post(
          '/messaging/conversations/$conversationId/mark_read/', {});
      return r.statusCode == 200;
    } catch (e) {
      debugPrint('markConversationAsRead error: $e');
      return false;
    }
  }

  Future<bool> deleteConversation(String conversationId) async {
    try {
      final response = await _delete('/messaging/conversations/$conversationId/');
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      debugPrint('deleteConversation error: $e');
      return false;
    }
  }

  // =====================
  // Lost & Found API Methods
  // =====================

  Future<List<LostFoundItem>> getLostFoundItems({
    LostFoundType? type,
    bool? showResolved,
    int page = 0,
    int pageSize = 10,
  }) async {
    final r = await _get('/lost-found/', params: {
      'page': '$page',
      'page_size': '$pageSize',
      if (type != null) 'type': type.toString().split('.').last,
      if (showResolved != null) 'resolved': showResolved ? 'true' : 'false',
    });
    final items = _results(r)
        .map((j) => LostFoundItem.fromJson(j as Map<String, dynamic>))
        .toList();
    // Populate cache so screens survive tab switches
    if (type == LostFoundType.lost) _cachedLostItems = items;
    if (type == LostFoundType.found) _cachedFoundItems = items;
    return items;
  }

  Future<bool> reportLostFoundItem(LostFoundItem item) async {
    try {
      final r = await _post('/lost-found/', {
        'title': item.title,
        'description': item.description,
        'location': item.location,
        'category': item.category ?? '',
        'itemDate': item.itemDate.toIso8601String().substring(0, 10),
        'type': item.type.toString().split('.').last,
        'imageUrls': item.imageUrls,
      });
      return r.statusCode == 201;
    } catch (e) {
      debugPrint('reportLostFoundItem error: $e');
      return false;
    }
  }

  Future<bool> markLostFoundAsResolved(
      String itemId, String? resolvedById) async {
    try {
      final r = await _post('/lost-found/$itemId/resolve/',
          {'resolvedById': resolvedById ?? ''});
      if (r.statusCode == 200) {
        NotificationService.instance.addLocalNotification(
          type: 'resolved',
          title: 'Item Resolved',
          body: 'Your lost & found item has been marked as resolved.',
        );
        return true;
      }
    } catch (e) {
      debugPrint('markLostFoundAsResolved error: $e');
    }
    return false;
  }

  Future<List<LostFoundItem>> searchLostFoundItemsByQuery(
      String query) async {
    try {
      final r = await _get('/lost-found/', params: {'q': query});
      return _results(r).map((j) => LostFoundItem.fromJson(j)).toList();
    } catch (e) {
      debugPrint('searchLostFoundItemsByQuery error: $e');
      return [];
    }
  }

  // =====================
  // Utility Methods
  // =====================

  Future<List<String>> getCategories() async {
    return [
      'Electronics', 'Books', 'Furniture',
      'Clothing', 'Sports', 'Stationery', 'Other',
    ];
  }

  Future<Map<String, dynamic>> globalSearch(String query) async {
    try {
      final r = await _get('/search/', params: {'q': query.trim()});
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body) as Map<String, dynamic>;
        return {
          'posts': (data['posts'] as List? ?? [])
              .map((j) => Post.fromJson(j))
              .toList(),
          'items': (data['items'] as List? ?? [])
              .map((j) => MarketplaceItem.fromJson(j))
              .toList(),
          'lostFound': (data['lostFound'] as List? ?? [])
              .map((j) => LostFoundItem.fromJson(j))
              .toList(),
          'users': (data['users'] as List? ?? [])
              .map((j) => UniMatesUser.fromJson(j))
              .toList(),
        };
      }
    } catch (e) {
      debugPrint('globalSearch error: $e');
    }
    return {};
  }

  void logoutCleanup() {
    _wishlistedItemIds.clear();
    debugPrint('ApiService: session data cleared on logout');
  }

  // =====================
  // Profile API Methods
  // =====================

  Future<UniMatesUser?> getUserProfile(String uid) async {
    try {
      // Use /users/me/ for the current user (Firebase UID is not a valid UUID
      // and the backend detail endpoint expects a Django UUID primary key).
      // For other users, uid must be their Django UUID (comes from post/item data).
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      final path = (uid == currentUid) ? '/users/me/' : '/users/$uid/';
      final r = await _get(path);
      if (r.statusCode == 200) {
        final profile = UniMatesUser.fromJson(jsonDecode(r.body));
        if (uid == currentUid) _cachedCurrentUserDjangoId = profile.id;
        return profile;
      }
    } catch (e) {
      debugPrint('getUserProfile error: $e');
    }
    return null;
  }

  Future<bool> updateUserProfile(UniMatesUser user) async {
    try {
      final r = await _patch('/users/me/', {
        'name': user.name,
        'username': user.username,
        if (user.bio != null) 'bio': user.bio,
        'university': user.university,
      });
      return r.statusCode == 200;
    } catch (e) {
      debugPrint('updateUserProfile error: $e');
      return false;
    }
  }

  /// Uploads a profile image for the current user and returns the new URL.
  Future<String?> updateProfileImage(String filePath) async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      final uri = Uri.parse('$_base/users/me/avatar/');
      final req = http.MultipartRequest('PATCH', uri);
      if (token != null) req.headers['Authorization'] = 'Bearer $token';
      req.files.add(await http.MultipartFile.fromPath('image', filePath));
      final streamed = await req.send();
      final body = await streamed.stream.bytesToString();
      if (streamed.statusCode == 200) {
        return jsonDecode(body)['profileImageUrl'] as String?;
      }
      debugPrint('updateProfileImage failed (${streamed.statusCode}): $body');
      return null;
    } catch (e) {
      debugPrint('updateProfileImage error: $e');
      return null;
    }
  }

  Future<List<Post>> getUserPosts(String userId) async {
    try {
      final r = await _get('/community/posts/', params: {
        'author': userId,
        'page': '0',
        'page_size': '50',
      });
      return _results(r).map((j) => Post.fromJson(j)).toList();
    } catch (e) {
      debugPrint('getUserPosts error: \$e');
      return [];
    }
  }

  Future<List<MarketplaceItem>> getUserListings(String userId) async {
    return getSellerListings(sellerId: userId);
  }

  Future<List<UniMatesUser>> searchUsers(String query) async {
    try {
      if (query.trim().isEmpty) return [];
      final r =
          await _get('/users/search/', params: {'q': query.trim()});
      return _results(r).map((j) => UniMatesUser.fromJson(j)).toList();
    } catch (e) {
      debugPrint('searchUsers error: $e');
      return [];
    }
  }

  // =====================
  // Reviews API Methods
  // =====================

  Future<List<Review>> getReviews(String targetUserId) async {
    try {
      final r = await _get('/reviews/',
          params: {'target_user_id': targetUserId});
      return _results(r).map((j) => Review.fromJson(j)).toList();
    } catch (e) {
      debugPrint('getReviews error: $e');
      return [];
    }
  }

  Future<bool> hasReviewed(String targetUserId) async {
    try {
      final r = await _get('/reviews/has_reviewed/',
          params: {'target_user_id': targetUserId});
      if (r.statusCode == 200) {
        return jsonDecode(r.body)['hasReviewed'] as bool;
      }
    } catch (e) {
      debugPrint('hasReviewed error: $e');
    }
    return false;
  }

  Future<String?> addReview({
    required String targetUserId,
    required double rating,
    required String comment,
  }) async {
    try {
      final r = await _post('/reviews/', {
        'targetUserId': targetUserId,
        'rating': rating,
        'comment': comment,
      });
      if (r.statusCode == 201) return null; // success
      // Return the backend error message
      try {
        final body = jsonDecode(r.body);
        if (body is Map) {
          final detail = body['detail'] ?? body.values.first;
          if (detail is List) return detail.first.toString();
          return detail.toString();
        }
      } catch (_) {}
      return 'Failed to submit review (${r.statusCode})';
    } catch (e) {
      debugPrint('addReview error: $e');
      return e.toString();
    }
  }

  // =====================
  // Wishlist API Methods
  // =====================

  bool isWishlisted(String itemId) => _wishlistedItemIds.contains(itemId);

  bool toggleWishlist(String itemId) {
    final nowWishlisted = !_wishlistedItemIds.contains(itemId);
    if (nowWishlisted) {
      _wishlistedItemIds.add(itemId);
    } else {
      _wishlistedItemIds.remove(itemId);
    }
    // Sync with backend in background
    unawaited(_post('/marketplace/wishlist/$itemId/toggle/', {})
        .catchError((_) => http.Response('', 500)));
    return nowWishlisted;
  }

  Future<List<MarketplaceItem>> getWishlist() async {
    try {
      final r = await _get('/marketplace/wishlist/');
      final items =
          _results(r).map((j) => MarketplaceItem.fromJson(j)).toList();
      // Keep local cache in sync
      _wishlistedItemIds
        ..clear()
        ..addAll(items.map((i) => i.id));
      return items;
    } catch (e) {
      debugPrint('getWishlist error: $e');
      return [];
    }
  }
}
