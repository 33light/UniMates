import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:unimates/models/app_models.dart';
import 'package:unimates/services/mock_api_service.dart';
import 'package:unimates/screens/profile/reviews.dart';
import 'edit_listing.dart';
import '../messaging/conversations_list.dart';

class ItemDetailScreen extends StatefulWidget {
  final MarketplaceItem item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  int _currentImageIndex = 0;
  late PageController _imageController;
  bool _isWishlisted = false;

  @override
  void initState() {
    super.initState();
    _imageController = PageController();
    _isWishlisted = MockApiService.instance.isWishlisted(widget.item.id);
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  String _formatPrice(double? price) {
    if (price == null) return 'Not specified';
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    return formatter.format(price);
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Future<void> _messageSeller(BuildContext context, User? currentUser) async {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to message the seller.')),
      );
      return;
    }

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final conversation =
          await MockApiService.instance.getOrCreateConversation(
        otherUserId: widget.item.userId,
        otherUserName: widget.item.sellerName,
        otherUserImage: widget.item.sellerImage ?? '',
        currentUserId: currentUser.uid,
        currentUserName:
            currentUser.displayName ?? currentUser.email ?? 'You',
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

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwnListing = widget.item.userId == (currentUser?.uid ?? '');
    final isSold = widget.item.isSold;
    final itemType = widget.item.type.toString().split('.').last.toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel
            if (widget.item.imageUrls.isNotEmpty)
              Stack(
                children: [
                  SizedBox(
                    height: 300,
                    child: PageView.builder(
                      controller: _imageController,
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
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  if (isSold)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black45,
                        child: const Center(
                          child: Text(
                            'SOLD',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Image indicator
                  if (widget.item.imageUrls.length > 1)
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_currentImageIndex + 1}/${widget.item.imageUrls.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 16),
            // Item Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.item.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  // Price & Type
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatPrice(widget.item.price),
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          itemType,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Category & Posted Date
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Category',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.item.category,
                              style:
                                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Posted',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(widget.item.createdAt),
                              style:
                                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.item.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  // Seller Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: widget.item.sellerImage != null
                              ? NetworkImage(widget.item.sellerImage!)
                              : null,
                          child: widget.item.sellerImage == null
                              ? Text(
                                  widget.item.sellerName.isNotEmpty ? widget.item.sellerName[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.item.sellerName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star_outlined,
                                      size: 16, color: Colors.orange),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.item.rating} (${widget.item.reviewsCount} reviews)',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: isOwnListing
                              ? const Icon(Icons.edit_outlined)
                              : const Icon(Icons.person_add_outlined),
                          tooltip: isOwnListing ? 'Edit listing' : 'Message seller',
                          onPressed: isOwnListing
                              ? () {
                                  final nav = Navigator.of(context);
                                  Navigator.push<MarketplaceItem>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditListingScreen(listing: widget.item),
                                    ),
                                  ).then((updated) {
                                    if (updated != null && mounted) {
                                      nav.pop(updated);
                                    }
                                  });
                                }
                              : () => _messageSeller(context, currentUser),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Exchange Terms (if applicable)
                  if (widget.item.type == ListingType.exchange &&
                      widget.item.exchangeTerms != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Exchange Terms',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(widget.item.exchangeTerms!),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  // Action Buttons
                  if (!isSold && !isOwnListing)
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _messageSeller(context, currentUser),
                            icon: const Icon(Icons.mail_outline),
                            label: const Text('Message Seller'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _isWishlisted = MockApiService.instance
                                    .toggleWishlist(widget.item.id);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(_isWishlisted
                                      ? 'Saved to wishlist'
                                      : 'Removed from wishlist'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            icon: Icon(_isWishlisted
                                ? Icons.bookmark
                                : Icons.bookmark_border),
                            label: Text(
                                _isWishlisted ? 'Saved' : 'Save Item'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReviewsScreen(
                                  targetUserId: widget.item.userId,
                                  targetUserName: widget.item.sellerName,
                                ),
                              ),
                            ),
                            icon: const Icon(Icons.star_border),
                            label: const Text('Rate Seller'),
                          ),
                        ),
                      ],
                    )
                  else
                    Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Item Sold',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
