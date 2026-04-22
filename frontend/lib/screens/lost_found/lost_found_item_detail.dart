import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../models/app_models.dart';
import '../../services/mock_api_service.dart';
import '../profile/reviews.dart';
import '../messaging/conversations_list.dart';

class LostFoundItemDetailScreen extends StatefulWidget {
  final LostFoundItem item;

  const LostFoundItemDetailScreen({
    super.key,
    required this.item,
  });

  @override
  State<LostFoundItemDetailScreen> createState() =>
      _LostFoundItemDetailScreenState();
}

class _LostFoundItemDetailScreenState extends State<LostFoundItemDetailScreen> {
  late PageController _pageController;
  int _currentImageIndex = 0;
  bool _isResolving = false;
  late bool _isResolved;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _isResolved = widget.item.isResolved;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isOwner = widget.item.reporterId == currentUserId;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: widget.item.imageUrls.isNotEmpty
                  ? PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() => _currentImageIndex = index);
                      },
                      itemCount: widget.item.imageUrls.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          widget.item.imageUrls[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: Icon(
                                widget.item.type == LostFoundType.lost
                                    ? Icons.help_outline
                                    : Icons.check_circle_outline,
                                size: 64,
                                color: Colors.grey[600],
                              ),
                            );
                          },
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: Icon(
                          widget.item.type == LostFoundType.lost
                              ? Icons.help_outline
                              : Icons.check_circle_outline,
                          size: 64,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image indicators
                  if (widget.item.imageUrls.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.item.imageUrls.length,
                          (index) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == index
                                  ? Colors.blue
                                  : Colors.grey[300],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Title and status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.item.title,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: widget.item.type == LostFoundType.lost
                                    ? Colors.red[100]
                                    : Colors.green[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.item.type == LostFoundType.lost
                                    ? 'LOST'
                                    : 'FOUND',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: widget.item.type == LostFoundType.lost
                                      ? Colors.red[700]
                                      : Colors.green[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_isResolved)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'RESOLVED',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.item.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Location and date info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        // Location
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.grey[600]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Location',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    widget.item.location,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Date
                        Row(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.grey[600]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.item.type == LostFoundType.lost
                                        ? 'Date Lost'
                                        : 'Date Found',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    DateFormat('MMM dd, yyyy')
                                        .format(widget.item.itemDate),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Reporter card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reporter',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            // Avatar
                            if (widget.item.reporterImage != null)
                              CircleAvatar(
                                radius: 24,
                                backgroundImage:
                                    NetworkImage(widget.item.reporterImage!),
                                onBackgroundImageError: (exception, stackTrace) {},
                              )
                            else
                              CircleAvatar(
                                radius: 24,
                                child: Text(
                                  widget.item.reporterName.isNotEmpty ? widget.item.reporterName[0].toUpperCase() : '?',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.item.reporterName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Posted ${_getTimeAgo(widget.item.createdAt)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!_isResolved)
                              ElevatedButton(
                                onPressed: () => _contactReporter(context),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  backgroundColor: Colors.blue,
                                ),
                                child: const Text(
                                  'Contact',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Mark as resolved button (only for the item's reporter)
                  if (!_isResolved && isOwner)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isResolving ? null : _markAsResolved,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: _isResolving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text('Mark as Resolved'),
                      ),
                    ),
                  // Rate Reporter (visible once resolved and not own item)
                  if (_isResolved && !isOwner)
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReviewsScreen(
                              targetUserId: widget.item.reporterId,
                              targetUserName: widget.item.reporterName,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.star_border),
                        label: const Text('Rate Reporter'),
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd').format(dateTime);
    }
  }

  Future<void> _contactReporter(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to contact the reporter.')),
      );
      return;
    }

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final conversation = await MockApiService.instance.getOrCreateConversation(
        otherUserId: widget.item.reporterId,
        otherUserName: widget.item.reporterName,
        otherUserImage: widget.item.reporterImage ?? '',
        currentUserId: currentUser.uid,
        currentUserName: currentUser.displayName ?? currentUser.email ?? 'You',
      );

      if (mounted) {
        navigator.push(
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              conversation: conversation,
              currentUserId: currentUser.uid,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Could not open chat: $e')),
        );
      }
    }
  }

  Future<void> _markAsResolved() async {
    setState(() => _isResolving = true);

    try {
      final currentUid = FirebaseAuth.instance.currentUser?.uid ?? 'current_user';
      final success = await MockApiService.instance
          .markLostFoundAsResolved(widget.item.id, currentUid);

      if (success) {
        if (mounted) {
          setState(() => _isResolved = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item marked as resolved!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResolving = false);
      }
    }
  }
}
