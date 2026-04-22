// Data Models for UniMates App
// These models define the structure of data across all modules

// =====================
// User Models
// =====================

class UniMatesUser {
  final String id;
  final String name;
  final String username;
  final String email;
  final String? profileImageUrl;
  final String university;
  final bool isVerified;
  final DateTime joinDate;
  final String? bio;
  final double rating;
  final int reviewsCount;

  UniMatesUser({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    this.profileImageUrl,
    required this.university,
    required this.isVerified,
    required this.joinDate,
    this.bio,
    this.rating = 5.0,
    this.reviewsCount = 0,
  });

  factory UniMatesUser.fromJson(Map<String, dynamic> json) {
    return UniMatesUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      university: json['university'] ?? '',
      isVerified: json['isVerified'] ?? false,
      joinDate: DateTime.parse(json['joinDate'] ?? DateTime.now().toString()),
      bio: json['bio'],
      rating: double.tryParse(json['rating']?.toString() ?? '5.0') ?? 5.0,
      reviewsCount: json['reviewsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'university': university,
      'isVerified': isVerified,
      'joinDate': joinDate.toIso8601String(),
      'bio': bio,
      'rating': rating,
      'reviewsCount': reviewsCount,
    };
  }
}

// =====================
// Community Models
// =====================

class Post {
  final String id;
  final String title;
  final String content;
  final UniMatesUser author;
  final List<String> imageUrls;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final bool? isLikedByCurrentUser;
  final bool isEvent;
  final DateTime? eventDate;
  final String? eventLocation;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    this.imageUrls = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
    this.isLikedByCurrentUser = false,
    this.isEvent = false,
    this.eventDate,
    this.eventLocation,
  });

  Post copyWith({
    int? likesCount,
    int? commentsCount,
    bool? isLikedByCurrentUser,
  }) {
    return Post(
      id: id,
      title: title,
      content: content,
      author: author,
      imageUrls: imageUrls,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      isEvent: isEvent,
      eventDate: eventDate,
      eventLocation: eventLocation,
    );
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      author: json['author'] != null
          ? UniMatesUser.fromJson(json['author'])
          : UniMatesUser(
              id: json['authorId'] ?? '',
              name: json['authorName'] ?? 'Unknown',
              username: json['authorUsername'] ?? 'unknown',
              email: json['authorEmail'] ?? '',
              profileImageUrl: json['authorImage'],
              university: '',
              isVerified: false,
              joinDate: DateTime.now(),
            ),
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      likesCount: json['likesCount'] ?? json['likes'] ?? 0,
      commentsCount: json['commentsCount'] ?? json['comments'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      isLikedByCurrentUser: json['isLikedByCurrentUser'] ?? false,
      isEvent: json['isEvent'] ?? false,
      eventDate: json['eventDate'] != null ? DateTime.tryParse(json['eventDate']) : null,
      eventLocation: json['eventLocation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author': author.toJson(),
      'imageUrls': imageUrls,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'createdAt': createdAt.toIso8601String(),
      'isLikedByCurrentUser': isLikedByCurrentUser,
      'isEvent': isEvent,
      'eventDate': eventDate?.toIso8601String(),
      'eventLocation': eventLocation,
    };
  }
}

class Comment {
  final String id;
  final String postId;
  final UniMatesUser author;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.author,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? '',
      postId: json['postId'] ?? '',
      author: json['author'] != null
          ? UniMatesUser.fromJson(json['author'])
          : UniMatesUser(
              id: json['authorId'] ?? '',
              name: json['authorName'] ?? 'Unknown',
              username: json['authorUsername'] ?? 'unknown',
              email: json['authorEmail'] ?? '',
              profileImageUrl: json['authorImage'],
              university: '',
              isVerified: false,
              joinDate: DateTime.now(),
            ),
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'author': author.toJson(),
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// =====================
// Marketplace Models
// =====================

enum ListingType {
  buy,
  sell,
  borrow,
  exchange,
}

class MarketplaceItem {
  final String id;
  final String userId;
  final String sellerName;
  final String? sellerImage;
  final String title;
  final String description;
  final List<String> imageUrls;
  final String category;
  final String? condition;
  final ListingType type;
  final double? price;
  final String? exchangeTerms;
  final DateTime createdAt;
  final bool isSold;
  final double rating;
  final int reviewsCount;

  MarketplaceItem({
    required this.id,
    required this.userId,
    required this.sellerName,
    this.sellerImage,
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.category,
    this.condition,
    required this.type,
    this.price,
    this.exchangeTerms,
    required this.createdAt,
    this.isSold = false,
    this.rating = 5.0,
    this.reviewsCount = 0,
  });

  factory MarketplaceItem.fromJson(Map<String, dynamic> json) {
    return MarketplaceItem(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      sellerName: json['sellerName'] ?? '',
      sellerImage: json['sellerImage'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      category: json['category'] ?? 'Other',
      condition: json['condition'],
      type: ListingType.values.firstWhere(
        (e) => e.toString().split('.').last == (json['type'] ?? 'sell'),
        orElse: () => ListingType.sell,
      ),
      price: json['price'] == null ? null : double.tryParse(json['price'].toString()),
      exchangeTerms: json['exchangeTerms'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      isSold: json['isSold'] ?? false,
      rating: double.tryParse(json['rating']?.toString() ?? '5.0') ?? 5.0,
      reviewsCount: json['reviewsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'sellerName': sellerName,
      'sellerImage': sellerImage,
      'title': title,
      'description': description,
      'imageUrls': imageUrls,
      'category': category,
      'condition': condition,
      'type': type.toString().split('.').last,
      'price': price,
      'exchangeTerms': exchangeTerms,
      'createdAt': createdAt.toIso8601String(),
      'isSold': isSold,
      'rating': rating,
      'reviewsCount': reviewsCount,
    };
  }

  // Helper getters
  String get typeLabel {
    switch (type) {
      case ListingType.buy:
        return 'Looking to Buy';
      case ListingType.sell:
        return 'For Sale';
      case ListingType.borrow:
        return 'For Borrow';
      case ListingType.exchange:
        return 'Exchange';
    }
  }

  String get priceLabel {
    if (price != null) return 'Rs. ${price!.toStringAsFixed(0)}';
    if (exchangeTerms != null) return exchangeTerms!;
    return 'Contact for price';
  }
}

// =====================
// Messaging Models
// =====================

class Conversation {
  final String id;
  final String userId1;
  final String userId2;
  final String user1Name;
  final String user2Name;
  final String? user1Image;
  final String? user2Image;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  Conversation({
    required this.id,
    required this.userId1,
    required this.userId2,
    required this.user1Name,
    required this.user2Name,
    this.user1Image,
    this.user2Image,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? '',
      userId1: json['userId1'] ?? '',
      userId2: json['userId2'] ?? '',
      user1Name: json['user1Name'] ?? '',
      user2Name: json['user2Name'] ?? '',
      user1Image: json['user1Image'],
      user2Image: json['user2Image'],
      lastMessage: json['lastMessage'] ?? '',
      lastMessageTime:
          DateTime.parse(json['lastMessageTime'] ?? DateTime.now().toString()),
      unreadCount: json['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId1': userId1,
      'userId2': userId2,
      'user1Name': user1Name,
      'user2Name': user2Name,
      'user1Image': user1Image,
      'user2Image': user2Image,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'unreadCount': unreadCount,
    };
  }

  // Get other user name based on current user
  String getOtherUserName(String currentUserId) {
    return currentUserId == userId1 ? user2Name : user1Name;
  }

  String? getOtherUserImage(String currentUserId) {
    return currentUserId == userId1 ? user2Image : user1Image;
  }
}

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String? senderImage;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final List<String>? imageUrls;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderImage,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.imageUrls,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      senderImage: json['senderImage'],
      content: json['content'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toString()),
      isRead: json['isRead'] ?? false,
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'senderImage': senderImage,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'imageUrls': imageUrls,
    };
  }
}

// =====================
// Lost & Found Models
// =====================

enum LostFoundType {
  lost,
  found,
}

class LostFoundItem {
  final String id;
  final String reporterId;
  final String reporterName;
  final String? reporterImage;
  final String title;
  final String description;
  final String location;
  final String? category;
  final DateTime itemDate; // Date when item was lost/found
  final List<String> imageUrls;
  final LostFoundType type;
  final bool isResolved;
  final DateTime createdAt;
  final String? resolvedBy; // User who reported found item (for lost items)

  LostFoundItem({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    this.reporterImage,
    required this.title,
    required this.description,
    required this.location,
    this.category,
    required this.itemDate,
    required this.imageUrls,
    required this.type,
    this.isResolved = false,
    required this.createdAt,
    this.resolvedBy,
  });

  LostFoundItem copyWith({bool? isResolved, String? resolvedBy}) {
    return LostFoundItem(
      id: id,
      reporterId: reporterId,
      reporterName: reporterName,
      reporterImage: reporterImage,
      title: title,
      description: description,
      location: location,
      category: category,
      itemDate: itemDate,
      imageUrls: imageUrls,
      type: type,
      isResolved: isResolved ?? this.isResolved,
      createdAt: createdAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
    );
  }

  factory LostFoundItem.fromJson(Map<String, dynamic> json) {
    return LostFoundItem(
      id: json['id'] ?? '',
      reporterId: json['reporterId'] ?? '',
      reporterName: json['reporterName'] ?? '',
      reporterImage: json['reporterImage'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      category: json['category'],
      itemDate: DateTime.parse(json['itemDate'] ?? DateTime.now().toString()),
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      type: LostFoundType.values.firstWhere(
        (e) => e.toString().split('.').last == (json['type'] ?? 'lost'),
        orElse: () => LostFoundType.lost,
      ),
      isResolved: json['isResolved'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      resolvedBy: json['resolvedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporterId': reporterId,
      'reporterName': reporterName,
      'reporterImage': reporterImage,
      'title': title,
      'description': description,
      'location': location,
      'category': category,
      'itemDate': itemDate.toIso8601String(),
      'imageUrls': imageUrls,
      'type': type.toString().split('.').last,
      'isResolved': isResolved,
      'createdAt': createdAt.toIso8601String(),
      'resolvedBy': resolvedBy,
    };
  }

  String get typeLabel => type == LostFoundType.lost ? 'Lost Item' : 'Found Item';
}

// =====================
// Review Models
// =====================

class Review {
  final String id;
  final String reviewerId;
  final String reviewerName;
  final String? reviewerImage;
  final String targetUserId; // Who is being reviewed
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.reviewerId,
    required this.reviewerName,
    this.reviewerImage,
    required this.targetUserId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      reviewerId: json['reviewerId'] ?? '',
      reviewerName: json['reviewerName'] ?? '',
      reviewerImage: json['reviewerImage'],
      targetUserId: json['targetUserId'] ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? '5.0') ?? 5.0,
      comment: json['comment'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'reviewerImage': reviewerImage,
      'targetUserId': targetUserId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// =====================
// Wishlist Models
// =====================

class WishlistItem {
  final String id;
  final String userId;
  final String marketplaceItemId;
  final DateTime addedAt;

  WishlistItem({
    required this.id,
    required this.userId,
    required this.marketplaceItemId,
    required this.addedAt,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      marketplaceItemId: json['marketplaceItemId'] ?? '',
      addedAt: DateTime.parse(json['addedAt'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'marketplaceItemId': marketplaceItemId,
      'addedAt': addedAt.toIso8601String(),
    };
  }
}
