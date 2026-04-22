import 'package:flutter/material.dart';
import 'package:unimates/models/app_models.dart';
import 'package:unimates/services/mock_api_service.dart';
import 'package:unimates/services/notification_service.dart';
import 'package:unimates/widgets/post_card.dart';
import 'package:unimates/screens/search/search_screen.dart';
import 'package:unimates/screens/notifications/notifications_screen.dart';
import 'create_post.dart';
import 'post_detail.dart';

class CommunityFeedScreen extends StatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  final MockApiService _apiService = MockApiService.instance;
  late Future<List<Post>> _postsFuture;
  final ScrollController _scrollController = ScrollController();
  late VoidCallback _notificationListener;
  
  // Pagination state
  int _currentPage = 0;
  final int _pageSize = 10;
  List<Post> _allPosts = [];
  bool _isLoadingMore = false;
  bool _hasMorePosts = true;
  String? _paginationError;

  @override
  void initState() {
    super.initState();
    _postsFuture = _fetchAndSetPosts(0);
    _scrollController.addListener(_onScroll);
    _notificationListener = () {
      if (mounted) setState(() {});
    };
    NotificationService.instance.addListener(_notificationListener);
  }

  Future<List<Post>> _fetchAndSetPosts(int page) async {
    final posts = await _apiService.getPosts(page: page, pageSize: _pageSize);
    if (mounted) {
      setState(() => _allPosts = posts);
    }
    return posts;
  }

  @override
  void dispose() {
    NotificationService.instance.removeListener(_notificationListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Load more posts when user scrolls near the bottom
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 500 &&
        !_isLoadingMore &&
        _hasMorePosts &&
        _paginationError == null) {
      _loadMorePosts();
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore) return;

    if (!mounted) return; // Safety check

    setState(() {
      _isLoadingMore = true;
      _paginationError = null;
    });

    try {
      final newPosts = await _apiService.getPosts(
        page: _currentPage + 1,
        pageSize: _pageSize,
      );

      if (!mounted) return; // Safety check after async operation

      if (newPosts.isEmpty) {
        // No more posts available
        setState(() => _hasMorePosts = false);
      } else {
        setState(() {
          _currentPage++;
          _allPosts.addAll(newPosts);
        });
      }
    } catch (e) {
      if (!mounted) return;
      
      debugPrint('Error loading more posts: $e');
      setState(() {
        _paginationError = 'Failed to load more posts';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  void _retryLoadingMore() {
    setState(() => _paginationError = null);
    _loadMorePosts();
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _currentPage = 0;
      _allPosts = [];
      _hasMorePosts = true;
      _isLoadingMore = false;
      _paginationError = null;
      _postsFuture = _fetchAndSetPosts(0);
    });
  }

  void _navigateToCreatePost() {
    Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const CreatePostScreen(),
      ),
    ).then((created) {
      if (created == true) _refreshPosts();
    });
  }

  void _navigateToPostDetail(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(post: post),
      ),
    );
  }

  void _handleLike(String postId) async {
    await _apiService.togglePostLike(postId);
    _refreshPosts();
  }

  void _handleComment(String postId) async {
    try {
      final post = await _apiService.getPost(postId);
      if (post != null && mounted) {
        _navigateToPostDetail(post);
      }
    } catch (e) {
      debugPrint('Error fetching post: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Feed'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                tooltip: 'Notifications',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                ),
              ),
              if (NotificationService.instance.unreadCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                        minWidth: 14, minHeight: 14),
                    child: Text(
                      '${NotificationService.instance.unreadCount}',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 8),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshPosts,
            tooltip: 'Refresh posts',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreatePost,
        tooltip: 'Create Post',
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: FutureBuilder<List<Post>>(
          future: _postsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && _allPosts.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError && _allPosts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading posts',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _refreshPosts,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }


            if (_allPosts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.inbox,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No posts yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Be the first to share something!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _navigateToCreatePost,
                      icon: const Icon(Icons.add),
                      label: const Text('Create Post'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              controller: _scrollController,
              itemCount: _allPosts.length + (_isLoadingMore ? 1 : 0) + (_paginationError != null ? 1 : 0),
              itemBuilder: (context, index) {
                // Show error message at the bottom
                if (_paginationError != null && index == _allPosts.length + (_isLoadingMore ? 1 : 0)) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red[400],
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _paginationError!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.red[400],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _retryLoadingMore,
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Show loading indicator at the bottom
                if (index == _allPosts.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: SizedBox(
                        height: 40,
                        width: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return PostCard(
                  post: _allPosts[index],
                  onTap: () => _navigateToPostDetail(_allPosts[index]),
                  onLike: _handleLike,
                  onComment: _handleComment,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
